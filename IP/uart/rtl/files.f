// uart RTL filelist. Packages first, then modules bottom-up.
// Source: vendor/opentitan/hw/ip/uart/rtl @ 365c167e

+incdir+$IP_ROOT/uart/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/uart/rtl/uart_reg_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/uart/rtl/uart.sv
$IP_ROOT/uart/rtl/uart_core.sv
$IP_ROOT/uart/rtl/uart_reg_top.sv
$IP_ROOT/uart/rtl/uart_rx.sv
$IP_ROOT/uart/rtl/uart_tx.sv
