// pwrmgr RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/top_earlgrey/ip_autogen/pwrmgr/rtl @ 365c167e
//
// Externally-owned packages this IP needs (copied in, listed first).
// These are NOT in common/ on purpose -- common.f carries what every
// IP needs, not what any IP might need. See IP/common/README.md.
//   lc_ctrl_state_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv
//   lc_ctrl_reg_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv
//   ibex_pkg.sv  <- hw/vendor/lowrisc_ibex/rtl/ibex_pkg.sv
//   rv_core_ibex_pkg.sv  <- hw/ip/rv_core_ibex/rtl/rv_core_ibex_pkg.sv
//   rom_ctrl_pkg.sv  <- hw/ip/rom_ctrl/rtl/rom_ctrl_pkg.sv
//   lc_ctrl_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv

+incdir+$IP_ROOT/pwrmgr/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/pwrmgr/rtl/ibex_pkg.sv
$IP_ROOT/pwrmgr/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/pwrmgr/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/pwrmgr/rtl/pwrmgr_reg_pkg.sv
$IP_ROOT/pwrmgr/rtl/rom_ctrl_pkg.sv
$IP_ROOT/pwrmgr/rtl/lc_ctrl_pkg.sv
$IP_ROOT/pwrmgr/rtl/pwrmgr_pkg.sv
$IP_ROOT/pwrmgr/rtl/rv_core_ibex_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/pwrmgr/rtl/prim_lc_sender.sv
$IP_ROOT/pwrmgr/rtl/prim_lc_sync.sv
$IP_ROOT/pwrmgr/rtl/pwrmgr.sv
$IP_ROOT/pwrmgr/rtl/pwrmgr_cdc.sv
$IP_ROOT/pwrmgr/rtl/pwrmgr_cdc_pulse.sv
$IP_ROOT/pwrmgr/rtl/pwrmgr_fsm.sv
$IP_ROOT/pwrmgr/rtl/pwrmgr_reg_top.sv
$IP_ROOT/pwrmgr/rtl/pwrmgr_slow_fsm.sv
$IP_ROOT/pwrmgr/rtl/pwrmgr_wake_info.sv
