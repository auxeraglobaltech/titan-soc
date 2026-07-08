// Re-opens chip_env_pkg to inject trainee vseqs without editing vendor/.
//
// Why: upstream vseqs are `include'd inside the package body (see
// chip_env_pkg.sv + chip_vseq_list.sv). A standalone compile unit cannot
// extend package-scoped types. SystemVerilog allows re-opening a package
// (IEEE 1800-2017 §26.2) — the second package...endpackage block appends
// identifiers to the already-compiled namespace, so our classes see
// chip_sw_base_vseq, cfg, DV_WAIT, etc.
//
// Compiled via build_opts in titan_sim_cfg.hjson:
//   build_opts: ["{self_dir}/titan_vseq_extras.sv"]
//
// To add a new trainee vseq:
//   1. Drop <name>_vseq.sv in tests/smoke/ (or tests/<subdir>/)
//   2. Add a `include line below
//   3. Add +incdir+ for its directory if it is not tests/smoke/

package chip_env_pkg;

  // Pull in macros again — the preprocessor state is NOT preserved across
  // package re-opens on Xcelium, so we need these before any `uvm_object_utils.
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // ---- Trainee vseqs (add one line per new vseq) ---------------------------
  `include "titan_hello_vseq.sv"

endpackage : chip_env_pkg
