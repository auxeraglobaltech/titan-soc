// titan-soc trainee template — Exercise 2 (advanced track): your first vseq.
//
// Pairs with sw/trainee/hello_test.c. The C side does the work; this vseq
// shows the UVM half of the handshake — how a chip-level sequence observes
// the software test status and synchronizes with it.
//
// Study first (all under vendor/opentitan/hw/top_earlgrey/dv/env/seq_lib/):
//   chip_sw_base_vseq.sv        — boot, backdoor SW load, status tracking
//   chip_sw_gpio_smoke_vseq.sv  — a real paired vseq (symbol backdoor, DV_WAIT)
//
// Registration (mechanism drafted, validation pending — see tests/smoke/README.md):
//   overlay entry:  uvm_test_seq: titan_hello_vseq  +  build_opts compile unit
//
// NOTE: this file is NOT yet compiled by any build — it is the authoring
// template for the first cohort to validate the overlay compile-unit path.

class titan_hello_vseq extends chip_sw_base_vseq;
  `uvm_object_utils(titan_hello_vseq)
  `uvm_object_new

  virtual task body();
    super.body();

    // The TEST ROM has run and our C payload is executing once the status
    // word (0x411f0080, watched by sw_test_status_if) reaches InTest.
    `DV_WAIT(cfg.sw_test_status_vif.sw_test_status == SwTestStatusInTest)
    `uvm_info(`gfn, "SW reached InTest — hello from the UVM side!", UVM_LOW)

    // --- Exercise 2a: read a SW symbol's address ------------------------
    // Use dv_utils_pkg::sw_symbol_get_addr_size() on the slot-A ELF to look
    // up a symbol from hello_test.c (add a global there first). See
    // chip_sw_gpio_smoke_vseq.sv::pre_randomize() for the exact call.

    // --- Exercise 2b: backdoor-inject a value ---------------------------
    // Overwrite your symbol with sw_symbol_backdoor_overwrite() in
    // cpu_init() (NOT here in body() — it must land before the CPU reads
    // it). Have the C side CHECK() the injected value.

    // PASS/FAIL still comes from the SW status word; the base classes
    // handle SwTestStatusPassed/Failed — nothing to do here.
  endtask

endclass
