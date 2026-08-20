// Full compile filelist for the rv_timer compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/rv_timer/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/rv_timer/verification/tests/rv_timer_test_pkg.sv
$IP_ROOT/rv_timer/verification/tb/tb.sv
