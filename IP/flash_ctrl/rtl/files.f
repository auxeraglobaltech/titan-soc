// flash_ctrl RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/top_earlgrey/ip_autogen/flash_ctrl/rtl @ 365c167e
//
// Externally-owned packages this IP needs (copied in, listed first).
// These are NOT in common/ on purpose -- common.f carries what every
// IP needs, not what any IP might need. See IP/common/README.md.
//   csrng_reg_pkg.sv  <- hw/ip/csrng/rtl/csrng_reg_pkg.sv
//   rom_ctrl_pkg.sv  <- hw/ip/rom_ctrl/rtl/rom_ctrl_pkg.sv
//   pwrmgr_reg_pkg.sv  <- hw/top_darjeeling/ip_autogen/pwrmgr/rtl/pwrmgr_reg_pkg.sv
//   lc_ctrl_state_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv
//   lc_ctrl_reg_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv
//   entropy_src_pkg.sv  <- hw/ip/entropy_src/rtl/entropy_src_pkg.sv
//   csrng_pkg.sv  <- hw/ip/csrng/rtl/csrng_pkg.sv
//   pwrmgr_pkg.sv  <- hw/top_darjeeling/ip_autogen/pwrmgr/rtl/pwrmgr_pkg.sv
//   otp_ctrl_pkg.sv  <- hw/ip/otp_ctrl/rtl/otp_ctrl_pkg.sv
//   lc_ctrl_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv
//   jtag_pkg.sv  <- hw/ip/rv_dm/rtl/jtag_pkg.sv
//   flash_ctrl_pkg.sv  <- hw/ip/flash_ctrl/rtl/flash_ctrl_pkg.sv
//   edn_pkg.sv  <- hw/ip/edn/rtl/edn_pkg.sv
//   ast_pkg.sv  <- hw/top_darjeeling/ip/ast/rtl/ast_pkg.sv

+incdir+$IP_ROOT/flash_ctrl/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/flash_ctrl/rtl/ast_pkg.sv
$IP_ROOT/flash_ctrl/rtl/csrng_reg_pkg.sv
$IP_ROOT/flash_ctrl/rtl/entropy_src_pkg.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_pkg.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_reg_pkg.sv
$IP_ROOT/flash_ctrl/rtl/jtag_pkg.sv
$IP_ROOT/flash_ctrl/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/flash_ctrl/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/flash_ctrl/rtl/pwrmgr_reg_pkg.sv
$IP_ROOT/flash_ctrl/rtl/rom_ctrl_pkg.sv
$IP_ROOT/flash_ctrl/rtl/csrng_pkg.sv
$IP_ROOT/flash_ctrl/rtl/lc_ctrl_pkg.sv
$IP_ROOT/flash_ctrl/rtl/edn_pkg.sv
$IP_ROOT/flash_ctrl/rtl/otp_ctrl_pkg.sv
$IP_ROOT/flash_ctrl/rtl/pwrmgr_pkg.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_top_specific_pkg.sv
$IP_ROOT/flash_ctrl/rtl/flash_phy_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/flash_ctrl/rtl/flash_ctrl.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_arb.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_core_reg_top.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_erase.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_info_cfg.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_lcmgr.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_prim_reg_top.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_prog.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_rd.sv
$IP_ROOT/flash_ctrl/rtl/flash_ctrl_region_cfg.sv
$IP_ROOT/flash_ctrl/rtl/flash_mp.sv
$IP_ROOT/flash_ctrl/rtl/flash_mp_data_region_sel.sv
$IP_ROOT/flash_ctrl/rtl/flash_phy.sv
$IP_ROOT/flash_ctrl/rtl/flash_phy_core.sv
$IP_ROOT/flash_ctrl/rtl/flash_phy_erase.sv
$IP_ROOT/flash_ctrl/rtl/flash_phy_prog.sv
$IP_ROOT/flash_ctrl/rtl/flash_phy_rd.sv
$IP_ROOT/flash_ctrl/rtl/flash_phy_rd_buf_dep.sv
$IP_ROOT/flash_ctrl/rtl/flash_phy_rd_buffers.sv
$IP_ROOT/flash_ctrl/rtl/flash_phy_scramble.sv
$IP_ROOT/flash_ctrl/rtl/prim_flash.sv
$IP_ROOT/flash_ctrl/rtl/prim_generic_flash_bank.sv
$IP_ROOT/flash_ctrl/rtl/prim_lc_sync.sv
$IP_ROOT/flash_ctrl/rtl/tlul_lc_gate.sv
