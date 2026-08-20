// Full compile filelist for the flash_ctrl compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/flash_ctrl/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/flash_ctrl/verification/tests/flash_ctrl_test_pkg.sv
$IP_ROOT/flash_ctrl/verification/tb/tb.sv
