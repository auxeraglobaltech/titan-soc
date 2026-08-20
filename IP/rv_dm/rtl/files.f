// rv_dm RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/rv_dm/rtl @ 365c167e
//
// Externally-owned packages this IP needs (copied in, listed first).
// These are NOT in common/ on purpose -- common.f carries what every
// IP needs, not what any IP might need. See IP/common/README.md.
//   lc_ctrl_state_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv
//   lc_ctrl_reg_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv
//   lc_ctrl_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv

+incdir+$IP_ROOT/rv_dm/rtl

$IP_ROOT/rv_dm/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/rv_dm/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/rv_dm/rtl/lc_ctrl_pkg.sv
$IP_ROOT/rv_dm/rtl/jtag_pkg.sv
$IP_ROOT/rv_dm/rtl/rv_dm_pkg.sv
$IP_ROOT/rv_dm/rtl/rv_dm_reg_pkg.sv
$IP_ROOT/rv_dm/rtl/rv_dm_dbg_reg_top.sv
$IP_ROOT/rv_dm/rtl/rv_dm_dmi_gate.sv
$IP_ROOT/rv_dm/rtl/rv_dm_mem_reg_top.sv
$IP_ROOT/rv_dm/rtl/rv_dm_regs_reg_top.sv
$IP_ROOT/rv_dm/rtl/rv_dm.sv
