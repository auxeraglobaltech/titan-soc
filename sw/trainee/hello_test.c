// titan-soc trainee template — Exercise 1: your first chip-level SW test.
//
// This is a minimal OTTF (OpenTitan Test Framework) test. The TEST ROM boots
// the chip, jumps to this program in flash slot A, and the UVM testbench
// watches the SW test status word at 0x411f0080 (see docs/XCELIUM_NOTES.md).
// Returning true from test_main() => SwTestStatusPassed => UVM reports PASS.
//
// Build target: //sw/device/tests/titan:hello_test  (see BUILD in this dir)
// Test entry  : titan_sw_hello_test                 (overlay/titan_sim_cfg.hjson)
// Run         : env TEST=titan_sw_hello_test ./sim/run_xcelium.sh

#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

OTTF_DEFINE_TEST_CONFIG();

bool test_main(void) {
  // LOG_INFO lands in the run dir:  sim/runs/<test>/tb...u_sw_logger_if.log
  LOG_INFO("Hello from titan-soc trainee test!");

  // --- Exercise 1a: read a device register ------------------------------
  // Use dif_* APIs (sw/device/lib/dif/) to poke real hardware, e.g. GPIO:
  // see sw/device/tests/gpio_smoketest.c in the OT tree for a worked example.

  // --- Exercise 1b: make it fail on purpose -----------------------------
  // Change `true` to `false`, rerun, and find the FAIL in run.log — know
  // what failure looks like BEFORE you need to debug a real one.

  return true;
}
