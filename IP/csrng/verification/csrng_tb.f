// Full compile filelist for the csrng compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/csrng/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/csrng/verification/tests/csrng_test_pkg.sv
$IP_ROOT/csrng/verification/tb/tb.sv
