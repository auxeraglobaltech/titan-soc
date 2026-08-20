// otbn RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/otbn/rtl @ 365c167e
//
// Externally-owned packages this IP needs (copied in, listed first).
// These are NOT in common/ on purpose -- common.f carries what every
// IP needs, not what any IP might need. See IP/common/README.md.
//   csrng_reg_pkg.sv  <- hw/ip/csrng/rtl/csrng_reg_pkg.sv
//   lc_ctrl_state_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv
//   lc_ctrl_reg_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv
//   keymgr_reg_pkg.sv  <- hw/ip/keymgr/rtl/keymgr_reg_pkg.sv
//   entropy_src_pkg.sv  <- hw/ip/entropy_src/rtl/entropy_src_pkg.sv
//   csrng_pkg.sv  <- hw/ip/csrng/rtl/csrng_pkg.sv
//   otp_ctrl_pkg.sv  <- hw/ip/otp_ctrl/rtl/otp_ctrl_pkg.sv
//   lc_ctrl_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv
//   keymgr_pkg.sv  <- hw/ip/keymgr/rtl/keymgr_pkg.sv
//   edn_pkg.sv  <- hw/ip/edn/rtl/edn_pkg.sv

+incdir+$IP_ROOT/otbn/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/otbn/rtl/csrng_reg_pkg.sv
$IP_ROOT/otbn/rtl/entropy_src_pkg.sv
$IP_ROOT/otbn/rtl/keymgr_reg_pkg.sv
$IP_ROOT/otbn/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/otbn/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/otbn/rtl/otbn_reg_pkg.sv
$IP_ROOT/otbn/rtl/csrng_pkg.sv
$IP_ROOT/otbn/rtl/keymgr_pkg.sv
$IP_ROOT/otbn/rtl/lc_ctrl_pkg.sv
$IP_ROOT/otbn/rtl/edn_pkg.sv
$IP_ROOT/otbn/rtl/otp_ctrl_pkg.sv
$IP_ROOT/otbn/rtl/otbn_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/otbn/rtl/otbn.sv
$IP_ROOT/otbn/rtl/otbn_alu_base.sv
$IP_ROOT/otbn/rtl/otbn_alu_bignum.sv
$IP_ROOT/otbn/rtl/otbn_controller.sv
$IP_ROOT/otbn/rtl/otbn_core.sv
$IP_ROOT/otbn/rtl/otbn_decoder.sv
$IP_ROOT/otbn/rtl/otbn_instruction_fetch.sv
$IP_ROOT/otbn/rtl/otbn_loop_controller.sv
$IP_ROOT/otbn/rtl/otbn_lsu.sv
$IP_ROOT/otbn/rtl/otbn_mac_bignum.sv
$IP_ROOT/otbn/rtl/otbn_mac_bignum_fsm.sv
$IP_ROOT/otbn/rtl/otbn_mai.sv
$IP_ROOT/otbn/rtl/otbn_mask_accelerator.sv
$IP_ROOT/otbn/rtl/otbn_mod_result_selector.sv
$IP_ROOT/otbn/rtl/otbn_predecode.sv
$IP_ROOT/otbn/rtl/otbn_reg_top.sv
$IP_ROOT/otbn/rtl/otbn_rf_base.sv
$IP_ROOT/otbn/rtl/otbn_rf_base_ff.sv
$IP_ROOT/otbn/rtl/otbn_rf_base_fpga.sv
$IP_ROOT/otbn/rtl/otbn_rf_bignum.sv
$IP_ROOT/otbn/rtl/otbn_rf_bignum_ff.sv
$IP_ROOT/otbn/rtl/otbn_rf_bignum_fpga.sv
$IP_ROOT/otbn/rtl/otbn_rnd.sv
$IP_ROOT/otbn/rtl/otbn_scramble_ctrl.sv
$IP_ROOT/otbn/rtl/otbn_sec_add.sv
$IP_ROOT/otbn/rtl/otbn_stack.sv
$IP_ROOT/otbn/rtl/otbn_start_stop_control.sv
$IP_ROOT/otbn/rtl/otbn_vec_adder.sv
$IP_ROOT/otbn/rtl/otbn_vec_multiplier.sv
$IP_ROOT/otbn/rtl/otbn_vec_shifter.sv
$IP_ROOT/otbn/rtl/otbn_vec_transposer.sv
$IP_ROOT/otbn/rtl/prim_edn_req.sv
$IP_ROOT/otbn/rtl/prim_lc_sync.sv
