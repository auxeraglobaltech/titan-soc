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

$IP_ROOT/csrng/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/csrng/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/csrng/rtl/aes_reg_pkg.sv
$IP_ROOT/csrng/rtl/lc_ctrl_pkg.sv
$IP_ROOT/csrng/rtl/entropy_src_pkg.sv
$IP_ROOT/csrng/rtl/aes_pkg.sv
$IP_ROOT/csrng/rtl/csrng_pkg.sv
$IP_ROOT/csrng/rtl/csrng_reg_pkg.sv
$IP_ROOT/csrng/rtl/csrng_block_encrypt.sv
$IP_ROOT/csrng/rtl/csrng_cmd_stage.sv
$IP_ROOT/csrng/rtl/csrng_core.sv
$IP_ROOT/csrng/rtl/csrng_ctr_drbg.sv
$IP_ROOT/csrng/rtl/csrng_main_sm.sv
$IP_ROOT/csrng/rtl/csrng_reg_top.sv
$IP_ROOT/csrng/rtl/csrng_state_db.sv
$IP_ROOT/csrng/rtl/csrng.sv
