// usbdev RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/usbdev/rtl @ 365c167e

+incdir+$IP_ROOT/usbdev/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/usbdev/rtl/usb_consts_pkg.sv
$IP_ROOT/usbdev/rtl/usbdev_pkg.sv
$IP_ROOT/usbdev/rtl/usbdev_reg_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/usbdev/rtl/usb_fs_nb_in_pe.sv
$IP_ROOT/usbdev/rtl/usb_fs_nb_out_pe.sv
$IP_ROOT/usbdev/rtl/usb_fs_nb_pe.sv
$IP_ROOT/usbdev/rtl/usb_fs_rx.sv
$IP_ROOT/usbdev/rtl/usb_fs_tx.sv
$IP_ROOT/usbdev/rtl/usb_fs_tx_mux.sv
$IP_ROOT/usbdev/rtl/usbdev.sv
$IP_ROOT/usbdev/rtl/usbdev_aon_wake.sv
$IP_ROOT/usbdev/rtl/usbdev_counter.sv
$IP_ROOT/usbdev/rtl/usbdev_iomux.sv
$IP_ROOT/usbdev/rtl/usbdev_linkstate.sv
$IP_ROOT/usbdev/rtl/usbdev_reg_top.sv
$IP_ROOT/usbdev/rtl/usbdev_usbif.sv
