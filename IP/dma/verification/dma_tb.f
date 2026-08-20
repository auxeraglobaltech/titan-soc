// Full compile filelist for the dma compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/dma/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/dma/verification/tests/dma_test_pkg.sv
$IP_ROOT/dma/verification/tb/tb.sv
