// hmac RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/hmac/rtl @ 365c167e

+incdir+$IP_ROOT/hmac/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/hmac/rtl/hmac_reg_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/hmac/rtl/hmac.sv
$IP_ROOT/hmac/rtl/hmac_core.sv
$IP_ROOT/hmac/rtl/hmac_reg_top.sv
