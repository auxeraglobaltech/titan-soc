// Full compile filelist for the adc_ctrl compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/adc_ctrl/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/adc_ctrl/verification/tests/adc_ctrl_test_pkg.sv
$IP_ROOT/adc_ctrl/verification/tb/tb.sv
