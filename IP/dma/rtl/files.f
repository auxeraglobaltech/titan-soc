// dma RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/dma/rtl @ 365c167e

+incdir+$IP_ROOT/dma/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/dma/rtl/dma_reg_pkg.sv
$IP_ROOT/dma/rtl/dma_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/dma/rtl/dma.sv
$IP_ROOT/dma/rtl/dma_reg_top.sv
