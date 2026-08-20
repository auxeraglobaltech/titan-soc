// Full compile filelist for the otbn compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/otbn/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/otbn/verification/tests/otbn_test_pkg.sv
$IP_ROOT/otbn/verification/tb/tb.sv
