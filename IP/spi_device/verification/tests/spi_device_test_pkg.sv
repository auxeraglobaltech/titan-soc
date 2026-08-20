// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// spi_device -- compile-check test package.
//
// One test, and it checks nothing. Its only job is to prove the UVM phasing
// runs to completion on top of an elaborated spi_device DUT.
//
// TODO(trainee): this package is where your real test library goes. Expect it
// to grow an env, a cfg object, a virtual sequencer, a RAL model and a
// seq_lib/ directory -- see ../README.md for the suggested order.

package spi_device_test_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class spi_device_base_test extends uvm_test;
    `uvm_component_utils(spi_device_base_test)

    virtual tb_clk_if clk_if;

    function new(string name = "spi_device_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual tb_clk_if)::get(this, "", "clk_if", clk_if)) begin
        `uvm_fatal(get_type_name(), "clk_if not found in config_db")
      end
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      clk_if.wait_for_reset_release();
      `uvm_info(get_type_name(), "reset released", UVM_LOW)

      // Nothing is driven and nothing is checked -- reaching the end without
      // an elaboration or phasing error is the entire pass criterion.
      clk_if.wait_clks(1000);

      `uvm_info(get_type_name(), "compile check complete -- TEST PASSED", UVM_LOW)

      phase.drop_objection(this);
    endtask

  endclass

endpackage
