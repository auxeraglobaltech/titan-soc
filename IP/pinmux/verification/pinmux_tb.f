// Full compile filelist for the pinmux compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/pinmux/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/pinmux/verification/tests/pinmux_test_pkg.sv
$IP_ROOT/pinmux/verification/tb/tb.sv
