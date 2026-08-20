// pwm RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/top_earlgrey/ip_autogen/pwm/rtl @ 365c167e

+incdir+$IP_ROOT/pwm/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/pwm/rtl/pwm_reg_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/pwm/rtl/pwm.sv
$IP_ROOT/pwm/rtl/pwm_chan.sv
$IP_ROOT/pwm/rtl/pwm_core.sv
$IP_ROOT/pwm/rtl/pwm_reg_top.sv
