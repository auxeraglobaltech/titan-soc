// titan-soc trainee test — CONN-2 extension: GPIO output self-check.
//
// Testplan: testplan/connectivity.md, CONN-2 (pad connectivity).
//   Feature       : GPIO output register -> pad ring -> pinmux -> back into
//                   the GPIO block's DATA_IN.
//   Pass criteria : every written pattern reads back identically on DATA_IN.
//   Coverage goal : all testable GPIOs toggled in both directions.
//
// C-ONLY test: no paired vseq. It runs under the default chip_sw_base_vseq
// (see `uvm_test_seq: chip_sw_base_vseq` at chip_sim_cfg.hjson:158), because
// the loopback path is entirely on-chip - nothing outside the pad ring needs
// to drive or observe anything. That also makes this test independent of the
// package re-open compile mechanism.
//
// Test entry : titan_sw_gpio_out_selfcheck_test (overlay/titan_sim_cfg.hjson)
// Run        : env TEST=titan_sw_gpio_out_selfcheck_test ./sim/run_xcelium.sh
//
// Contrast with chip_sw_gpio_smoketest, which checks the same path but has
// the testbench observe the pins externally. Here the check is closed
// entirely in software, which is why no vseq is needed.

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_gpio.h"
#include "sw/device/lib/dif/dif_pinmux.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/pinmux_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

static const dt_gpio_t kGpioDt = kDtGpio;
static const dt_pinmux_t kPinmuxDt = kDtPinmuxAon;

static_assert(kDtGpioPeriphIoGpio0 == 0, "kDtGpioPeriphIoGpio0 expected to be 0");
static_assert(kDtGpioPeriphIoCount == kDifGpioNumPins,
              "kDtGpioPeriphIoCount does not match kDifGpioNumPins");

static dif_gpio_t gpio;
static dif_pinmux_t pinmux;

OTTF_DEFINE_TEST_CONFIG();

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
 * Writes `val`, reads DATA_IN back, and checks the masked values match.
 *
 * The output travels out through the pad ring and back in through pinmux
 * synchronizers, so the read cannot be issued immediately - hence the
 * settle delay, same as upstream gpio_smoketest.c uses.
 */
static void write_and_check(uint32_t val, uint32_t mask, const char *what) {
  CHECK_DIF_OK(dif_gpio_write_all(&gpio, val));

  // Let the outputs propagate through the pad ring and the input
  // synchronizers. Different pins may arrive at slightly different times.
  busy_spin_micros(1);

  uint32_t read_val = 0;
  CHECK_DIF_OK(dif_gpio_read_all(&gpio, &read_val));

  uint32_t expected = val & mask;
  uint32_t actual = read_val & mask;
  CHECK(expected == actual, "%s: DATA_IN mismatch (exp: %x, obs: %x)", what,
        expected, actual);
}

bool test_main(void) {
  CHECK_DIF_OK(dif_pinmux_init_from_dt(kPinmuxDt, &pinmux));
  pinmux_testutils_init(&pinmux);
  configure_pinmux();

  CHECK_DIF_OK(dif_gpio_init_from_dt(kGpioDt, &gpio));

  // Not every GPIO is bonded out on every target; only check the ones that
  // actually loop back.
  uint32_t mask = pinmux_testutils_get_testable_gpios_mask();
  LOG_INFO("Testable GPIO mask: %x", mask);
  CHECK(mask != 0, "No testable GPIOs on this target");

  // Drive ALL pins as outputs, not just the testable ones, even though we
  // only CHECK the testable ones. dif_gpio_read_all() reads the whole 32-bit
  // DATA_IN, so any pin left un-driven would float and put an X into the
  // read data, tripping tlul_assert's dKnown_A on the TL-UL response.
  // Masking the comparison is not enough - the X has already reached the bus
  // by then. See docs/XCELIUM_NOTES.md quirk #14.
  CHECK_DIF_OK(dif_gpio_output_set_enabled_all(&gpio, 0xFFFFFFFFu));

  // --- Walking 1s: 0001, 0010, 0100, ... ---------------------------------
  // Catches pins shorted together and pins stuck low.
  for (uint32_t i = 0; i < kDifGpioNumPins; ++i) {
    if (!(mask & (1u << i))) {
      continue;
    }
    write_and_check(1u << i, mask, "walking 1");
  }

  // --- Walking 0s: 1110, 1101, 1011, ... ---------------------------------
  // Catches pins stuck high, which walking 1s alone would miss.
  for (uint32_t i = 0; i < kDifGpioNumPins; ++i) {
    if (!(mask & (1u << i))) {
      continue;
    }
    write_and_check(~(1u << i), mask, "walking 0");
  }

  // --- All-0s / all-1s and an alternating pair ---------------------------
  write_and_check(0x00000000, mask, "all 0s");
  write_and_check(0xFFFFFFFF, mask, "all 1s");
  write_and_check(0xAAAAAAAA, mask, "alternating A");
  write_and_check(0x55555555, mask, "alternating 5");

  // Leave the pins low rather than floating at whatever the last pattern was.
  write_and_check(0x00000000, mask, "final all 0s");

  LOG_INFO("GPIO output self-check passed on mask %x", mask);
  return true;
}
