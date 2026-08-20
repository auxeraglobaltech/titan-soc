// spi_host RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/spi_host/rtl @ 365c167e
//
// Externally-owned packages this IP needs (copied in, listed first).
// These are NOT in common/ on purpose -- common.f carries what every
// IP needs, not what any IP might need. See IP/common/README.md.
//   spi_device_reg_pkg.sv  <- hw/ip/spi_device/rtl/spi_device_reg_pkg.sv
//   spi_device_pkg.sv  <- hw/ip/spi_device/rtl/spi_device_pkg.sv

+incdir+$IP_ROOT/spi_host/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/spi_host/rtl/spi_device_reg_pkg.sv
$IP_ROOT/spi_host/rtl/spi_host_cmd_pkg.sv
$IP_ROOT/spi_host/rtl/spi_host_reg_pkg.sv
$IP_ROOT/spi_host/rtl/spi_device_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/spi_host/rtl/spi_host.sv
$IP_ROOT/spi_host/rtl/spi_host_byte_merge.sv
$IP_ROOT/spi_host/rtl/spi_host_byte_select.sv
$IP_ROOT/spi_host/rtl/spi_host_command_queue.sv
$IP_ROOT/spi_host/rtl/spi_host_core.sv
$IP_ROOT/spi_host/rtl/spi_host_data_fifos.sv
$IP_ROOT/spi_host/rtl/spi_host_fsm.sv
$IP_ROOT/spi_host/rtl/spi_host_reg_top.sv
$IP_ROOT/spi_host/rtl/spi_host_shift_register.sv
$IP_ROOT/spi_host/rtl/spi_host_window.sv
