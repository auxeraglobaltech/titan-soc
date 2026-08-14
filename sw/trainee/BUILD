# titan-soc trainee tests — bazel package synced to
# vendor/opentitan/sw/device/tests/titan/ by scripts/sync_trainee_sw.sh.
#
# One opentitan_test() per trainee test. The `sim_dv` exec env builds the
# image the DV testbench loads into flash slot A.

load("//rules/opentitan:defs.bzl", "opentitan_test")

package(default_visibility = ["//visibility:public"])

opentitan_test(
    name = "hello_test",
    srcs = ["hello_test.c"],
    exec_env = {
        "//hw/top_earlgrey:sim_dv": None,
    },
    deps = [
        "//sw/device/lib/base:memory",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)

# INT-3: GPIO interrupt on input edge. Paired with
# tests/smoke/titan_gpio_irq_vseq.sv, which drives the edges.
# Deps mirror //sw/device/tests/sim_dv:gpio_test, the upstream GPIO IRQ test.
opentitan_test(
    name = "gpio_irq_test",
    srcs = ["gpio_irq_test.c"],
    exec_env = {
        "//hw/top_earlgrey:sim_dv": None,
    },
    deps = [
        "//sw/device/lib/arch:device",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/dif:gpio",
        "//sw/device/lib/dif:rv_plic",
        "//sw/device/lib/runtime:hart",
        "//sw/device/lib/runtime:irq",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing:pinmux_testutils",
        "//sw/device/lib/testing:rv_plic_testutils",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)

# CONN-2 extension: GPIO output loopback, checked entirely in SW.
# No rv_plic deps - this test takes no interrupts.
opentitan_test(
    name = "gpio_out_selfcheck_test",
    srcs = ["gpio_out_selfcheck_test.c"],
    exec_env = {
        "//hw/top_earlgrey:sim_dv": None,
    },
    deps = [
        "//sw/device/lib/arch:device",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/dif:gpio",
        "//sw/device/lib/runtime:hart",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing:pinmux_testutils",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)

# INT-1 extension: repeated rv_timer deadlines.
# Deps mirror //sw/device/tests:rv_timer_smoketest. The timer IRQ is taken
# directly by Ibex, so there is no rv_plic dep here either.
opentitan_test(
    name = "rv_timer_irq_test",
    srcs = ["rv_timer_irq_test.c"],
    exec_env = {
        "//hw/top_earlgrey:sim_dv": None,
    },
    deps = [
        "//hw/top/dt",
        "//sw/device/lib/arch:device",
        "//sw/device/lib/dif:rv_timer",
        "//sw/device/lib/runtime:hart",
        "//sw/device/lib/runtime:ibex",
        "//sw/device/lib/runtime:irq",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)
