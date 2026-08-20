// pinmux RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/top_earlgrey/ip_autogen/pinmux/rtl @ 365c167e
//
// Externally-owned packages this IP needs (copied in, listed first).
// These are NOT in common/ on purpose -- common.f carries what every
// IP needs, not what any IP might need. See IP/common/README.md.
//   lc_ctrl_state_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv
//   lc_ctrl_reg_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv
//   lc_ctrl_pkg.sv  <- hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv
//   jtag_pkg.sv  <- hw/ip/rv_dm/rtl/jtag_pkg.sv

+incdir+$IP_ROOT/pinmux/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/pinmux/rtl/jtag_pkg.sv
$IP_ROOT/pinmux/rtl/lc_ctrl_reg_pkg.sv
$IP_ROOT/pinmux/rtl/lc_ctrl_state_pkg.sv
$IP_ROOT/pinmux/rtl/pinmux_reg_pkg.sv
$IP_ROOT/pinmux/rtl/usbdev_pkg.sv
$IP_ROOT/pinmux/rtl/lc_ctrl_pkg.sv
$IP_ROOT/pinmux/rtl/pinmux_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/pinmux/rtl/pinmux.sv
$IP_ROOT/pinmux/rtl/pinmux_jtag_breakout.sv
$IP_ROOT/pinmux/rtl/pinmux_jtag_buf.sv
$IP_ROOT/pinmux/rtl/pinmux_reg_top.sv
$IP_ROOT/pinmux/rtl/pinmux_strap_sampling.sv
$IP_ROOT/pinmux/rtl/pinmux_wkup.sv
$IP_ROOT/pinmux/rtl/prim_lc_or_hardened.sv
$IP_ROOT/pinmux/rtl/prim_lc_sender.sv
$IP_ROOT/pinmux/rtl/prim_lc_sync.sv
$IP_ROOT/pinmux/rtl/usbdev_aon_wake.sv
