// pattgen RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/pattgen/rtl @ 365c167e

+incdir+$IP_ROOT/pattgen/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/pattgen/rtl/pattgen_ctrl_pkg.sv
$IP_ROOT/pattgen/rtl/pattgen_reg_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/pattgen/rtl/pattgen.sv
$IP_ROOT/pattgen/rtl/pattgen_chan.sv
$IP_ROOT/pattgen/rtl/pattgen_core.sv
$IP_ROOT/pattgen/rtl/pattgen_reg_top.sv
