// adc_ctrl RTL filelist. Packages first, then modules.
// Source: vendor/opentitan/hw/ip/adc_ctrl/rtl @ 365c167e
//
// Externally-owned packages this IP needs (copied in, listed first).
// These are NOT in common/ on purpose -- common.f carries what every
// IP needs, not what any IP might need. See IP/common/README.md.
//   ast_pkg.sv  <- hw/top_darjeeling/ip/ast/rtl/ast_pkg.sv

+incdir+$IP_ROOT/adc_ctrl/rtl

// Packages, topologically sorted by their actual cross-references.
// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.
$IP_ROOT/adc_ctrl/rtl/adc_ctrl_pkg.sv
$IP_ROOT/adc_ctrl/rtl/adc_ctrl_reg_pkg.sv
$IP_ROOT/adc_ctrl/rtl/ast_pkg.sv

// Modules. Order does not matter in SystemVerilog.
$IP_ROOT/adc_ctrl/rtl/adc_ctrl.sv
$IP_ROOT/adc_ctrl/rtl/adc_ctrl_core.sv
$IP_ROOT/adc_ctrl/rtl/adc_ctrl_fsm.sv
$IP_ROOT/adc_ctrl/rtl/adc_ctrl_intr.sv
$IP_ROOT/adc_ctrl/rtl/adc_ctrl_reg_top.sv
