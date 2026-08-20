// Full compile filelist for the spi_host compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/spi_host/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/spi_host/verification/tests/spi_host_test_pkg.sv
$IP_ROOT/spi_host/verification/tb/tb.sv
