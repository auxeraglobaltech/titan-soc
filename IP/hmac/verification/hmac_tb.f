// Full compile filelist for the hmac compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/hmac/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/hmac/verification/tests/hmac_test_pkg.sv
$IP_ROOT/hmac/verification/tb/tb.sv
