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
