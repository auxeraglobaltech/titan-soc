// gpio RTL filelist. Packages first, then modules bottom-up.
// Source: vendor/opentitan/hw/top_earlgrey/ip_autogen/gpio/rtl @ 365c167e
// NOTE: this is the Earl Grey *generated* instance of the gpio template
// (NumIOs = 32). The template itself lives in hw/ip_templates/gpio.

+incdir+$IP_ROOT/gpio/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/gpio/rtl/gpio_pkg.sv
$IP_ROOT/gpio/rtl/gpio_reg_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/gpio/rtl/gpio.sv
$IP_ROOT/gpio/rtl/gpio_reg_top.sv
