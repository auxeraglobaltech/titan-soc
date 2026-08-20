// Full compile filelist for the mbx compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/mbx/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/mbx/verification/tests/mbx_test_pkg.sv
$IP_ROOT/mbx/verification/tb/tb.sv
