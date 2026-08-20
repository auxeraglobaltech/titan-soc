// Full compile filelist for the aes compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/aes/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/aes/verification/tests/aes_test_pkg.sv
$IP_ROOT/aes/verification/tb/tb.sv
