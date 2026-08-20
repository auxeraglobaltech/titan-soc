// Full compile filelist for the i2c compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/i2c/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/i2c/verification/tests/i2c_test_pkg.sv
$IP_ROOT/i2c/verification/tb/tb.sv
