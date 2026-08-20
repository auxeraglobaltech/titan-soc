// Full compile filelist for the spi_device compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/spi_device/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/spi_device/verification/tests/spi_device_test_pkg.sv
$IP_ROOT/spi_device/verification/tb/tb.sv
