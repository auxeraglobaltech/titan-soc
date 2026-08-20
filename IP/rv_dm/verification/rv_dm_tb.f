// Full compile filelist for the rv_dm compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/rv_dm/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/rv_dm/verification/tests/rv_dm_test_pkg.sv
$IP_ROOT/rv_dm/verification/tb/tb.sv
