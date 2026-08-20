// kmac RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/kmac/rtl @ 365c167e
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

+incdir+$IP_ROOT/kmac/rtl

$IP_ROOT/kmac/rtl/csrng_reg_pkg.sv
$IP_ROOT/kmac/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/kmac/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/kmac/rtl/keymgr_reg_pkg.sv
$IP_ROOT/kmac/rtl/entropy_src_pkg.sv
$IP_ROOT/kmac/rtl/csrng_pkg.sv
$IP_ROOT/kmac/rtl/lc_ctrl_pkg.sv
$IP_ROOT/kmac/rtl/keymgr_pkg.sv
$IP_ROOT/kmac/rtl/edn_pkg.sv
$IP_ROOT/kmac/rtl/kmac_pkg.sv
$IP_ROOT/kmac/rtl/kmac_reg_pkg.sv
$IP_ROOT/kmac/rtl/sha3_pkg.sv
$IP_ROOT/kmac/rtl/keccak_2share.sv
$IP_ROOT/kmac/rtl/keccak_round.sv
$IP_ROOT/kmac/rtl/kmac_app.sv
$IP_ROOT/kmac/rtl/kmac_core.sv
$IP_ROOT/kmac/rtl/kmac_entropy.sv
$IP_ROOT/kmac/rtl/kmac_errchk.sv
$IP_ROOT/kmac/rtl/kmac_msgfifo.sv
$IP_ROOT/kmac/rtl/kmac_reduced.sv
$IP_ROOT/kmac/rtl/kmac_reg_top.sv
$IP_ROOT/kmac/rtl/kmac_staterd.sv
$IP_ROOT/kmac/rtl/kmac.sv
$IP_ROOT/kmac/rtl/sha3pad.sv
$IP_ROOT/kmac/rtl/sha3.sv
