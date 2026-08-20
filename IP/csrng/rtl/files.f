// csrng RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/csrng/rtl @ 365c167e
//
// Externally-owned packages this IP needs (copied in, listed first).
// These are NOT in common/ on purpose -- common.f carries what every
// IP needs, not what any IP might need. See IP/common/README.md.
//   lc_ctrl_state_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv
//   lc_ctrl_reg_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv
//   aes_reg_pkg.sv  <- hw/ip/aes/rtl/aes_reg_pkg.sv
//   lc_ctrl_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv
//   entropy_src_pkg.sv  <- hw/ip/entropy_src/rtl/entropy_src_pkg.sv
//   aes_pkg.sv  <- hw/ip/aes/rtl/aes_pkg.sv

+incdir+$IP_ROOT/csrng/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/csrng/rtl/aes_reg_pkg.sv
$IP_ROOT/csrng/rtl/aes_sbox_canright_pkg.sv
$IP_ROOT/csrng/rtl/csrng_reg_pkg.sv
$IP_ROOT/csrng/rtl/entropy_src_pkg.sv
$IP_ROOT/csrng/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/csrng/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/csrng/rtl/aes_pkg.sv
$IP_ROOT/csrng/rtl/csrng_pkg.sv
$IP_ROOT/csrng/rtl/lc_ctrl_pkg.sv
$IP_ROOT/csrng/rtl/edn_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/csrng/rtl/aes_cipher_control.sv
$IP_ROOT/csrng/rtl/aes_cipher_control_fsm.sv
$IP_ROOT/csrng/rtl/aes_cipher_control_fsm_n.sv
$IP_ROOT/csrng/rtl/aes_cipher_control_fsm_p.sv
$IP_ROOT/csrng/rtl/aes_cipher_core.sv
$IP_ROOT/csrng/rtl/aes_key_expand.sv
$IP_ROOT/csrng/rtl/aes_mix_columns.sv
$IP_ROOT/csrng/rtl/aes_mix_single_column.sv
$IP_ROOT/csrng/rtl/aes_prng_masking.sv
$IP_ROOT/csrng/rtl/aes_sbox.sv
$IP_ROOT/csrng/rtl/aes_sbox_canright.sv
$IP_ROOT/csrng/rtl/aes_sbox_canright_masked.sv
$IP_ROOT/csrng/rtl/aes_sbox_canright_masked_noreuse.sv
$IP_ROOT/csrng/rtl/aes_sbox_dom.sv
$IP_ROOT/csrng/rtl/aes_sbox_lut.sv
$IP_ROOT/csrng/rtl/aes_sel_buf_chk.sv
$IP_ROOT/csrng/rtl/aes_shift_rows.sv
$IP_ROOT/csrng/rtl/aes_sub_bytes.sv
$IP_ROOT/csrng/rtl/csrng.sv
$IP_ROOT/csrng/rtl/csrng_block_encrypt.sv
$IP_ROOT/csrng/rtl/csrng_cmd_stage.sv
$IP_ROOT/csrng/rtl/csrng_core.sv
$IP_ROOT/csrng/rtl/csrng_ctr_drbg.sv
$IP_ROOT/csrng/rtl/csrng_main_sm.sv
$IP_ROOT/csrng/rtl/csrng_reg_top.sv
$IP_ROOT/csrng/rtl/csrng_state_db.sv
$IP_ROOT/csrng/rtl/prim_lc_sync.sv
