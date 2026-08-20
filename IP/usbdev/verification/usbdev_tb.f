// Full compile filelist for the usbdev compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/usbdev/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/usbdev/verification/tests/usbdev_test_pkg.sv
$IP_ROOT/usbdev/verification/tb/tb.sv
