// Full compile filelist for the gpio compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/gpio/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/gpio/verification/tests/gpio_test_pkg.sv
$IP_ROOT/gpio/verification/tb/tb.sv
