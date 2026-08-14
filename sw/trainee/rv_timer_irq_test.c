// titan-soc trainee test — INT-1 extension: repeated RV timer interrupts.
//
// Testplan: testplan/integration.md, INT-1 (rv_timer -> PLIC -> Ibex).
//   Feature       : rv_timer compare fires -> Ibex timer IRQ -> ISR runs,
//                   repeatedly, with the counter monotonically advancing.
//   Pass criteria : ISR observes the expected tick count; exactly one IRQ
//                   per armed deadline.
//   Coverage goal : timer IRQ line exercised across several deadlines.
//
// C-ONLY test: no paired vseq. Runs under the default chip_sw_base_vseq.
// The rv_timer is entirely internal, so nothing outside the chip needs to
// participate - which also keeps this test independent of the package
// re-open compile mechanism.
//
// Test entry : titan_sw_rv_timer_irq_test (overlay/titan_sim_cfg.hjson)
// Run        : env TEST=titan_sw_rv_timer_irq_test ./sim/run_xcelium.sh
//
// Modelled on vendor/opentitan/sw/device/tests/rv_timer_smoketest.c, which
// arms a single deadline. This one re-arms in a loop, which is what catches
// the bugs a single-shot test cannot: a stale comparator, an IRQ that fails
// to re-assert after acknowledge, or a counter that stops advancing.
//
// Note the timer IRQ is a CLIC/CSR interrupt taken directly by Ibex - it
// does NOT route through the PLIC, so this overrides ottf_timer_isr rather
// than ottf_external_isr (contrast sw/trainee/gpio_irq_test.c).

#include "hw/top/dt/api.h"       // Generated
#include "hw/top/dt/rv_timer.h"  // Generated
#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/dif/dif_rv_timer.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/irq.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

static dif_rv_timer_t timer;
static dt_rv_timer_t kRvTimerDt = (dt_rv_timer_t)0;
static_assert(kDtRvTimerCount >= 1,
              "This test requires at least one RV Timer instance");

enum {
  kHart = 0,
  kComparator = 0,
  // How many times we arm the timer and expect an interrupt back.
  kNumDeadlines = 5,
};

static const uint64_t kTickFreqHz = 1000 * 1000;  // 1 MHz.

// Set false before arming, set true by the ISR. Starts true so that a
// spurious interrupt taken before the first arm is caught.
static volatile bool irq_fired = true;
// Total ISR entries, checked against kNumDeadlines at the end.
static volatile uint32_t irq_count;

static void timer_handler(void) {
  // If this trips, an interrupt arrived that we had not armed for.
  CHECK(!irq_fired, "Entered timer ISR but irq_fired was already true");

  bool irq_flag;
  CHECK_DIF_OK(dif_rv_timer_irq_is_pending(
      &timer, kDtRvTimerIrqTimerExpiredHart0Timer0, &irq_flag));
  CHECK(irq_flag, "Entered timer ISR but the IRQ flag was not set");

  // Stop the counter while we service, then acknowledge. test_main re-enables
  // it when it arms the next deadline.
  CHECK_DIF_OK(
      dif_rv_timer_counter_set_enabled(&timer, kHart, kDifToggleDisabled));
  CHECK_DIF_OK(dif_rv_timer_irq_acknowledge(
      &timer, kDtRvTimerIrqTimerExpiredHart0Timer0));

  ++irq_count;
  irq_fired = true;
}

// Override the default OTTF timer ISR.
void ottf_timer_isr(uint32_t *exc_info) { timer_handler(); }

OTTF_DEFINE_TEST_CONFIG();

bool test_main(void) {
  irq_global_ctrl(true);
  irq_timer_ctrl(true);

  CHECK_DIF_OK(dif_rv_timer_init_from_dt(kRvTimerDt, &timer));
  CHECK_DIF_OK(dif_rv_timer_reset(&timer));

  dif_rv_timer_tick_params_t tick_params;
  CHECK_DIF_OK(dif_rv_timer_approximate_tick_params(
      dt_clock_frequency(dt_rv_timer_clock(kRvTimerDt, kDtRvTimerClockClk)),
      kTickFreqHz, &tick_params));
  CHECK_DIF_OK(dif_rv_timer_set_tick_params(&timer, kHart, tick_params));
  CHECK_DIF_OK(dif_rv_timer_irq_set_enabled(
      &timer, kDtRvTimerIrqTimerExpiredHart0Timer0, kDifToggleEnabled));

  // Logging over UART is slow on silicon/FPGA, so the deadline has to be
  // generous there. In DV there is no UART overhead, so a short deadline
  // keeps sim time down. Same split as upstream rv_timer_smoketest.c.
  uint64_t deadline = (kDeviceType == kDeviceSimDV) ? 100    /* 100 us */
                                                    : 30000 /* 30 ms */;

  uint64_t previous_time = 0;
  for (uint32_t i = 0; i < kNumDeadlines; ++i) {
    uint64_t current_time;
    CHECK_DIF_OK(dif_rv_timer_counter_read(&timer, kHart, &current_time));

    // The counter must never go backwards across deadlines. This is the
    // check a single-shot test cannot make.
    CHECK(current_time >= previous_time,
          "Timer counter went backwards (prev: %d, now: %d)",
          (uint32_t)previous_time, (uint32_t)current_time);
    previous_time = current_time;

    LOG_INFO("Deadline %d: arming at %d for %d", i, (uint32_t)current_time,
             (uint32_t)(current_time + deadline));
    CHECK_DIF_OK(
        dif_rv_timer_arm(&timer, kHart, kComparator, current_time + deadline));

    irq_fired = false;
    CHECK_DIF_OK(
        dif_rv_timer_counter_set_enabled(&timer, kHart, kDifToggleEnabled));

    while (!irq_fired) {
      wait_for_interrupt();
    }

    // Exactly one interrupt per deadline - no more, no less.
    CHECK(irq_count == i + 1, "Wrong IRQ count after deadline %d (exp: %d, obs: %d)",
          i, i + 1, irq_count);
  }

  CHECK(irq_count == kNumDeadlines, "Wrong total IRQ count (exp: %d, obs: %d)",
        kNumDeadlines, irq_count);

  LOG_INFO("RV timer IRQ test passed: %d deadlines, %d interrupts",
           kNumDeadlines, irq_count);
  return true;
}
