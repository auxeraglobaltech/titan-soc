// Full compile filelist for the pwm compile-check TB.
// Used by ../sim/run_compile.sh. $IP_ROOT is exported by that script.

-f $IP_ROOT/common/common.f
-f $IP_ROOT/pwm/rtl/files.f

$IP_ROOT/common/tb/tb_clk_if.sv
$IP_ROOT/pwm/verification/tests/pwm_test_pkg.sv
$IP_ROOT/pwm/verification/tb/tb.sv
