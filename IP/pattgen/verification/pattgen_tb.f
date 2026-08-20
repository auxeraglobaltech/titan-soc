// Full compile filelist for the pattgen compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/pattgen/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/pattgen/verification/tests/pattgen_test_pkg.sv
$IP_ROOT/pattgen/verification/tb/tb.sv
