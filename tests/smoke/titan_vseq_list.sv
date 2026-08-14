// titan-soc trainee vseq list.
//
// Included from vendor/opentitan/hw/top_earlgrey/dv/env/seq_lib/chip_vseq_list.sv
// at the very end, behind `ifdef TITAN_VSEQ_EXTRAS. The define is supplied by
// build_opts in overlay/titan_sim_cfg.hjson, so a plain upstream build (no
// define) is completely unaffected.
//
// WHY THIS SHAPE — the two things that killed the earlier approach:
//
//   1. ORDERING. dvsim emits our build_opts BEFORE "-f {sv_flist}"
//      (vendor/opentitan/hw/dv/tools/dvsim/xcelium.hjson:10-17). Any .sv file
//      we add via build_opts is therefore compiled before chip_env_pkg even
//      exists, so chip_sw_base_vseq is not a visible type yet. Nothing added
//      through build_opts can ever see package internals.
//
//   2. IMPORTS ARE PER PACKAGE-BLOCK. Re-opening a package appends
//      identifiers but does NOT inherit the earlier block's import
//      statements. chip_env_pkg imports ~40 packages (chip_env_pkg.sv:8-40);
//      a re-opened block starts with none of them, so even `uvm_object_utils
//      fails on uvm_object_registry.
//
// Being included INSIDE the original package block solves both at once: we
// land after every vendor vseq is declared, with every import already in
// scope. See docs/XCELIUM_NOTES.md.
//
// To add a new trainee vseq:
//   1. Drop <name>_vseq.sv in tests/smoke/
//   2. Add one `include line below
//   3. Register the test in overlay/titan_sim_cfg.hjson with
//      `uvm_test_seq: <name>_vseq`

`include "titan_hello_vseq.sv"
`include "titan_gpio_irq_vseq.sv"   // INT-3, pairs with gpio_irq_test.c
