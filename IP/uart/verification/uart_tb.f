// Full compile filelist for the uart compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/uart/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/uart/verification/tests/uart_test_pkg.sv
$IP_ROOT/uart/verification/tb/tb.sv
