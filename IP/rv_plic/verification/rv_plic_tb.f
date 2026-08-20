// Full compile filelist for the rv_plic compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/rv_plic/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/rv_plic/verification/tests/rv_plic_test_pkg.sv
$IP_ROOT/rv_plic/verification/tb/tb.sv
