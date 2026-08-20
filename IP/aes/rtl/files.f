// aes RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/aes/rtl @ 365c167e
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
//   lc_ctrl_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv
//   keymgr_pkg.sv  <- hw/ip/keymgr/rtl/keymgr_pkg.sv
//   edn_pkg.sv  <- hw/ip/edn/rtl/edn_pkg.sv

+incdir+$IP_ROOT/aes/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/aes/rtl/aes_reg_pkg.sv
$IP_ROOT/aes/rtl/aes_sbox_canright_pkg.sv
$IP_ROOT/aes/rtl/csrng_reg_pkg.sv
$IP_ROOT/aes/rtl/entropy_src_pkg.sv
$IP_ROOT/aes/rtl/keymgr_reg_pkg.sv
$IP_ROOT/aes/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/aes/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/aes/rtl/aes_pkg.sv
$IP_ROOT/aes/rtl/csrng_pkg.sv
$IP_ROOT/aes/rtl/keymgr_pkg.sv
$IP_ROOT/aes/rtl/lc_ctrl_pkg.sv
$IP_ROOT/aes/rtl/edn_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/aes/rtl/aes.sv
$IP_ROOT/aes/rtl/aes_cipher_control.sv
$IP_ROOT/aes/rtl/aes_cipher_control_fsm.sv
$IP_ROOT/aes/rtl/aes_cipher_control_fsm_n.sv
$IP_ROOT/aes/rtl/aes_cipher_control_fsm_p.sv
$IP_ROOT/aes/rtl/aes_cipher_core.sv
$IP_ROOT/aes/rtl/aes_control.sv
$IP_ROOT/aes/rtl/aes_control_fsm.sv
$IP_ROOT/aes/rtl/aes_control_fsm_n.sv
$IP_ROOT/aes/rtl/aes_control_fsm_p.sv
$IP_ROOT/aes/rtl/aes_core.sv
$IP_ROOT/aes/rtl/aes_ctr.sv
$IP_ROOT/aes/rtl/aes_ctr_fsm.sv
$IP_ROOT/aes/rtl/aes_ctr_fsm_n.sv
$IP_ROOT/aes/rtl/aes_ctr_fsm_p.sv
$IP_ROOT/aes/rtl/aes_ctrl_gcm_reg_shadowed.sv
$IP_ROOT/aes/rtl/aes_ctrl_reg_shadowed.sv
$IP_ROOT/aes/rtl/aes_ghash.sv
$IP_ROOT/aes/rtl/aes_ghash_wrap.sv
$IP_ROOT/aes/rtl/aes_key_expand.sv
$IP_ROOT/aes/rtl/aes_mix_columns.sv
$IP_ROOT/aes/rtl/aes_mix_single_column.sv
$IP_ROOT/aes/rtl/aes_prng_clearing.sv
$IP_ROOT/aes/rtl/aes_prng_masking.sv
$IP_ROOT/aes/rtl/aes_reduced_round.sv
$IP_ROOT/aes/rtl/aes_reg_status.sv
$IP_ROOT/aes/rtl/aes_reg_top.sv
$IP_ROOT/aes/rtl/aes_sbox.sv
$IP_ROOT/aes/rtl/aes_sbox_canright.sv
$IP_ROOT/aes/rtl/aes_sbox_canright_masked.sv
$IP_ROOT/aes/rtl/aes_sbox_canright_masked_noreuse.sv
$IP_ROOT/aes/rtl/aes_sbox_dom.sv
$IP_ROOT/aes/rtl/aes_sbox_lut.sv
$IP_ROOT/aes/rtl/aes_sel_buf_chk.sv
$IP_ROOT/aes/rtl/aes_shift_rows.sv
$IP_ROOT/aes/rtl/aes_sub_bytes.sv
$IP_ROOT/aes/rtl/aes_wrap.sv
$IP_ROOT/aes/rtl/prim_lc_sync.sv
