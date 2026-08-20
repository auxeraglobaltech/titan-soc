// aon_timer RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/aon_timer/rtl @ 365c167e
//
// Externally-owned packages this IP needs (copied in, listed first).
// These are NOT in common/ on purpose -- common.f carries what every
// IP needs, not what any IP might need. See IP/common/README.md.
//   lc_ctrl_state_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv
//   lc_ctrl_reg_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv
//   lc_ctrl_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv

+incdir+$IP_ROOT/aon_timer/rtl

$IP_ROOT/aon_timer/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/aon_timer/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/aon_timer/rtl/lc_ctrl_pkg.sv
$IP_ROOT/aon_timer/rtl/aon_timer_reg_pkg.sv
$IP_ROOT/aon_timer/rtl/aon_timer_core.sv
$IP_ROOT/aon_timer/rtl/aon_timer_reg_top.sv
$IP_ROOT/aon_timer/rtl/aon_timer.sv
