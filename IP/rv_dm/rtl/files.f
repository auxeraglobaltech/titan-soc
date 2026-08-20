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

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/rv_dm/rtl/dm_pkg.sv
$IP_ROOT/rv_dm/rtl/jtag_pkg.sv
$IP_ROOT/rv_dm/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/rv_dm/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/rv_dm/rtl/rv_dm_pkg.sv
$IP_ROOT/rv_dm/rtl/rv_dm_reg_pkg.sv
$IP_ROOT/rv_dm/rtl/lc_ctrl_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/rv_dm/rtl/debug_rom.sv
$IP_ROOT/rv_dm/rtl/debug_rom_one_scratch.sv
$IP_ROOT/rv_dm/rtl/dm_csrs.sv
$IP_ROOT/rv_dm/rtl/dm_mem.sv
$IP_ROOT/rv_dm/rtl/dm_sba.sv
$IP_ROOT/rv_dm/rtl/dm_top.sv
$IP_ROOT/rv_dm/rtl/dmi_cdc.sv
$IP_ROOT/rv_dm/rtl/dmi_jtag.sv
$IP_ROOT/rv_dm/rtl/dmi_jtag_tap.sv
$IP_ROOT/rv_dm/rtl/prim_lc_or_hardened.sv
$IP_ROOT/rv_dm/rtl/prim_lc_sender.sv
$IP_ROOT/rv_dm/rtl/prim_lc_sync.sv
$IP_ROOT/rv_dm/rtl/rv_dm.sv
$IP_ROOT/rv_dm/rtl/rv_dm_dbg_reg_top.sv
$IP_ROOT/rv_dm/rtl/rv_dm_dmi_gate.sv
$IP_ROOT/rv_dm/rtl/rv_dm_mem_reg_top.sv
$IP_ROOT/rv_dm/rtl/rv_dm_regs_reg_top.sv
$IP_ROOT/rv_dm/rtl/tlul_adapter_dmi.sv
$IP_ROOT/rv_dm/rtl/tlul_lc_gate.sv
