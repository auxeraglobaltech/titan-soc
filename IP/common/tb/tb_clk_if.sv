// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Minimal clock/reset interface shared by every IP compile-check testbench.
//
// This is deliberately tiny -- it only lets a UVM test wait for clock edges
// and for reset release without hierarchical references into tb. It is NOT a
// substitute for `clk_rst_if` in vendor/opentitan/hw/dv/sv/common_ifs, which
// is what you should switch to once you build a real environment (it can
// generate the clock, randomise the phase, and drive reset).

interface tb_clk_if (
  input logic clk,
  input logic rst_n
);

  // Wait for n posedges of the clock.
  task automatic wait_clks(int unsigned n);
    repeat (n) @(posedge clk);
  endtask

  // Wait until reset has been released.
  task automatic wait_for_reset_release();
    if (!rst_n) @(posedge rst_n);
    @(posedge clk);
  endtask

endinterface
