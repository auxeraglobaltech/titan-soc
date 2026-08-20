// Full compile filelist for the kmac compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/kmac/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/kmac/verification/tests/kmac_test_pkg.sv
$IP_ROOT/kmac/verification/tb/tb.sv
