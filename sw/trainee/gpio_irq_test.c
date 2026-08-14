// titan-soc trainee test — INT-3: GPIO interrupt on input edge.
//
// Testplan: testplan/integration.md, INT-3.
//   Feature       : DV drives a GPIO input edge -> gpio IP raises IRQ ->
//                   SW ISR handles it.
//   Pass criteria : ISR fires exactly once per edge, correct pin ID read
//                   from INTR_STATE.
//   Coverage goal : rising + falling edge interrupts on >= 4 pins.
//
// Paired vseq : tests/smoke/titan_gpio_irq_vseq.sv  (drives the edges)
// Test entry  : titan_sw_gpio_irq_test              (overlay/titan_sim_cfg.hjson)
// Run         : env TEST=titan_sw_gpio_irq_test ./sim/run_xcelium.sh
//
// Modelled on vendor/opentitan/sw/device/tests/sim_dv/gpio_test.c, which is
// the upstream GPIO input/IRQ test paired with chip_sw_gpio_vseq. The
// differences here are deliberate and are the point of the exercise:
//
//   * Upstream walks a thermometer pattern over all 32 pins. We use 4 pins
//     and check BOTH edges on each, which is the INT-3 coverage goal and
//     keeps the sim short enough for the smoke set.
//   * Upstream relies on generous TB delays alone to know when SW has armed
//     its interrupts. We add an explicit level handshake first (see
//     "Synchronization" below) so the arming window cannot race the first
//     edge.

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_gpio.h"
#include "sw/device/lib/dif/dif_pinmux.h"
#include "sw/device/lib/dif/dif_rv_plic.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/irq.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/pinmux_testutils.h"
#include "sw/device/lib/testing/rv_plic_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

static const dt_gpio_t kGpioDt = kDtGpio;
static const dt_pinmux_t kPinmuxDt = kDtPinmuxAon;
static const dt_rv_plic_t kRvPlicDt = kDtRvPlic;

enum {
  kPlicTarget = 0,
  // INT-3 coverage goal is ">= 4 pins", both edges. Pins 0..3.
  kNumTestPins = 4,
  // How long to let the TB take the pins over after we release them. Must be
  // shorter than ARM_DELAY_CLKS in the vseq, which covers this plus arming.
  kHandshakeSettleUsec = 50,
};

// Assume GPIO pins and GPIO IRQs are both numbered 0, 1, ... so that IRQ i
// belongs to pin i. Upstream gpio_test.c makes the same assumption.
static_assert(kDtGpioPeriphIoGpio0 == 0, "kDtGpioPeriphIoGpio0 expected to be 0");
static_assert(kDtGpioIrqGpio0 == 0, "kDtGpioIrqGpio0 expected to be 0");
static_assert(kDtGpioPeriphIoCount == kDifGpioNumPins,
              "kDtGpioPeriphIoCount does not match kDifGpioNumPins");

static dif_gpio_t gpio;
static dif_pinmux_t pinmux;
static dif_rv_plic_t plic;

// Mask of the pins this test drives interrupts on: pins 0..kNumTestPins-1.
static const uint32_t kTestPinMask = (1u << kNumTestPins) - 1;

// --- ISR <-> test_main communication -------------------------------------
// All volatile: written by the ISR, read by the main loop.

// The pin whose IRQ we expect next.
static volatile uint32_t expected_gpio_pin_irq;
// The level the pin should read once its expected edge has landed:
// true for a rising edge, false for a falling edge.
static volatile bool expected_irq_edge;
// Total ISR entries. The pass criteria is "exactly once per edge", so this
// must equal 2 * kNumTestPins at the end - no more, no less.
static volatile uint32_t irq_count;

/**
 * External IRQ handler, overriding the default OTTF external ISR.
 *
 * Every check that makes INT-3 meaningful lives here: that the IRQ came from
 * GPIO, that it came from the pin we expected, that INTR_STATE names that
 * one pin and no other, and that the pin level matches the edge polarity.
 */
void ottf_external_isr(uint32_t *exc_info) {
  // Find which interrupt fired at the PLIC by claiming it.
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(dif_rv_plic_irq_claim(&plic, kPlicTarget, &plic_irq_id));

  // It must have come from the GPIO block.
  dt_instance_id_t inst_id = dt_plic_id_to_instance_id(plic_irq_id);
  CHECK(inst_id == dt_gpio_instance_id(kGpioDt),
        "IRQ from wrong peripheral (exp: %d, obs: %d)",
        dt_gpio_instance_id(kGpioDt), inst_id);

  // Map the PLIC ID back to a GPIO pin number.
  uint32_t gpio_pin_irq_fired = dt_gpio_irq_from_plic_id(kGpioDt, plic_irq_id);
  CHECK(gpio_pin_irq_fired == expected_gpio_pin_irq,
        "Wrong GPIO pin IRQ (exp: %d, obs: %d)", expected_gpio_pin_irq,
        gpio_pin_irq_fired);

  // INTR_STATE must show exactly this one pin pending. A second bit here
  // means an edge we did not expect also fired - that is the "exactly once
  // per edge" half of the pass criteria.
  uint32_t gpio_irqs_status;
  CHECK_DIF_OK(dif_gpio_irq_get_state(&gpio, &gpio_irqs_status));
  CHECK(gpio_irqs_status == (1u << expected_gpio_pin_irq),
        "Wrong INTR_STATE (exp: %x, obs: %x)", 1u << expected_gpio_pin_irq,
        gpio_irqs_status);

  // The pin level must agree with the edge polarity we are expecting.
  bool pin_val;
  CHECK_DIF_OK(dif_gpio_read(&gpio, expected_gpio_pin_irq, &pin_val));
  CHECK(pin_val == expected_irq_edge, "Wrong GPIO %d level (exp: %d, obs: %d)",
        expected_gpio_pin_irq, expected_irq_edge, pin_val);

  ++irq_count;

  // Clear at the GPIO block, then complete at the PLIC. Order matters: if we
  // completed at the PLIC first, the still-pending GPIO line would
  // immediately re-assert and we would re-enter for the same edge.
  CHECK_DIF_OK(dif_gpio_irq_acknowledge(&gpio, gpio_pin_irq_fired));
  CHECK_DIF_OK(dif_rv_plic_irq_complete(&plic, kPlicTarget, plic_irq_id));
}

OTTF_DEFINE_TEST_CONFIG();

/**
 * Routes every GPIO periph_io to its test pad, as upstream gpio_test.c does.
 */
static void configure_pinmux(void) {
  for (size_t i = 0; i < kDifGpioNumPins; ++i) {
    dt_periph_io_t periph_io =
        dt_gpio_periph_io(kGpioDt, kDtGpioPeriphIoGpio0 + i);
    dt_pad_t pad = kPinmuxTestutilsGpioPads[i];
    CHECK_STATUS_OK(
        pinmux_testutils_connect(&pinmux, periph_io, kDtPeriphIoDirInout, pad));
  }
}

/**
 * Waits for one edge per test pin, pins 0..kNumTestPins-1 in order.
 *
 * `rising` selects the polarity the ISR will check the pin level against.
 */
static void await_edges(bool rising) {
  LOG_INFO("Waiting for %s edges on pins 0..%d",
           rising ? "rising" : "falling", kNumTestPins - 1);

  expected_irq_edge = rising;
  for (uint32_t pin = 0; pin < kNumTestPins; ++pin) {
    expected_gpio_pin_irq = pin;
    uint32_t seen_before = irq_count;
    // wait_for_interrupt() parks the hart until the ISR runs. Loop because
    // WFI may also wake on other events.
    while (irq_count == seen_before) {
      wait_for_interrupt();
    }
  }
}

bool test_main(void) {
  // --- Bring up pinmux, GPIO and PLIC ------------------------------------
  CHECK_DIF_OK(dif_pinmux_init_from_dt(kPinmuxDt, &pinmux));
  pinmux_testutils_init(&pinmux);
  configure_pinmux();

  CHECK_DIF_OK(dif_gpio_init_from_dt(kGpioDt, &gpio));
  CHECK_DIF_OK(dif_rv_plic_init_from_dt(kRvPlicDt, &plic));

  // The 4 pins we use must actually be testable on this target.
  uint32_t testable = pinmux_testutils_get_testable_gpios_mask();
  CHECK((testable & kTestPinMask) == kTestPinMask,
        "Pins 0..%d are not all testable (testable mask = %x)",
        kNumTestPins - 1, testable);

  // --- Synchronization with the vseq -------------------------------------
  // The TB cannot see our register writes, so we hand off using pin levels,
  // which it CAN see. Three steps:
  //
  //   1. We drive the test pins high as outputs.  -> "SW is alive"
  //   2. We release them (output disable => z).   -> "pins are yours"
  //   3. The vseq drives ALL pins low; we wait a
  //      fixed settle time for that to happen.    -> "TB has the pins"
  //
  // !! DO NOT read DATA_IN between steps 2 and 3 !!
  // Between the release and the TB taking over, the pads float. Reading
  // DATA_IN then returns X, and an X in a TL-UL response data word trips
  // tlul_assert's dKnown_A / dDataKnown_M and kills the run. An earlier
  // version polled DATA_IN here and died at the first read. This is also
  // why the vseq drives all NUM_GPIOS pins rather than just the 4 we use:
  // dif_gpio_read_all() reads the whole 32-bit register, so ANY floating
  // pin poisons the read. See docs/XCELIUM_NOTES.md quirk #14.
  //
  // Arming only after the pins are settled at 0 also stops a spurious
  // falling edge (our driven 1 -> the TB's driven 0) from being latched,
  // which would break the "exactly once per edge" criteria.
  CHECK_DIF_OK(dif_gpio_output_set_enabled_all(&gpio, kTestPinMask));
  CHECK_DIF_OK(dif_gpio_write_all(&gpio, kTestPinMask));
  LOG_INFO("Handshake: driving test pins high");

  CHECK_DIF_OK(dif_gpio_output_set_enabled_all(&gpio, 0u));
  LOG_INFO("Handshake: released pins, letting TB take over");
  busy_spin_micros(kHandshakeSettleUsec);
  LOG_INFO("Handshake: TB has the pins, arming interrupts");

  // --- Arm the interrupts ------------------------------------------------
  // Noise filter on: the TB drives clean edges, but the filter is what the
  // real design uses and it keeps synchronizer glitches out of INTR_STATE.
  CHECK_DIF_OK(dif_gpio_input_noise_filter_set_enabled(&gpio, kTestPinMask,
                                                       kDifToggleEnabled));
  CHECK_DIF_OK(dif_gpio_irq_set_trigger(&gpio, kTestPinMask,
                                        kDifGpioIrqTriggerEdgeRisingFalling));

  // Clear anything latched during the handshake before we unmask, so the
  // first IRQ we take is genuinely the vseq's first edge.
  CHECK_DIF_OK(dif_gpio_irq_acknowledge_all(&gpio));

  uint32_t enable_mask = kTestPinMask;
  CHECK_DIF_OK(dif_gpio_irq_restore_all(&gpio, &enable_mask));

  dt_plic_irq_id_t first_irq = dt_gpio_irq_to_plic_id(kGpioDt, kDtGpioIrqGpio0);
  rv_plic_testutils_irq_range_enable(&plic, kPlicTarget, first_irq,
                                     first_irq + kNumTestPins - 1);

  irq_global_ctrl(true);
  irq_external_ctrl(true);

  // --- The actual test ---------------------------------------------------
  // The vseq now walks pins 0..3 high one at a time, then low one at a time.
  await_edges(/*rising=*/true);
  await_edges(/*rising=*/false);

  // Every pin should read low again after the falling sweep.
  uint32_t read_val;
  CHECK_DIF_OK(dif_gpio_read_all(&gpio, &read_val));
  CHECK((read_val & kTestPinMask) == 0,
        "Pins should be low after falling sweep (obs: %x)",
        read_val & kTestPinMask);

  // "Exactly once per edge": 4 pins x 2 edges. A higher count means a
  // spurious or double interrupt slipped through.
  uint32_t expected_irqs = 2 * kNumTestPins;
  CHECK(irq_count == expected_irqs, "Wrong IRQ count (exp: %d, obs: %d)",
        expected_irqs, irq_count);

  LOG_INFO("GPIO IRQ test passed: %d edges, %d interrupts", expected_irqs,
           irq_count);
  return true;
}
