// spi_device RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/spi_device/rtl @ 365c167e

+incdir+$IP_ROOT/spi_device/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/spi_device/rtl/spi_device_reg_pkg.sv
$IP_ROOT/spi_device/rtl/spi_device_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/spi_device/rtl/spi_cmdparse.sv
$IP_ROOT/spi_device/rtl/spi_device.sv
$IP_ROOT/spi_device/rtl/spi_device_reg_top.sv
$IP_ROOT/spi_device/rtl/spi_p2s.sv
$IP_ROOT/spi_device/rtl/spi_passthrough.sv
$IP_ROOT/spi_device/rtl/spi_readcmd.sv
$IP_ROOT/spi_device/rtl/spi_s2p.sv
$IP_ROOT/spi_device/rtl/spi_tpm.sv
$IP_ROOT/spi_device/rtl/spid_addr_4b.sv
$IP_ROOT/spi_device/rtl/spid_csb_sync.sv
$IP_ROOT/spi_device/rtl/spid_dpram.sv
$IP_ROOT/spi_device/rtl/spid_fifo2sram_adapter.sv
$IP_ROOT/spi_device/rtl/spid_jedec.sv
$IP_ROOT/spi_device/rtl/spid_readbuffer.sv
$IP_ROOT/spi_device/rtl/spid_readsram.sv
$IP_ROOT/spi_device/rtl/spid_status.sv
$IP_ROOT/spi_device/rtl/spid_upload.sv
