// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// rv_plic -- COMPILE-CHECK TESTBENCH
//
// A skeleton, not a verification environment. It proves the rv_plic RTL and
// its dependencies elaborate and a UVM test can start and finish. No agent,
// no scoreboard, no RAL, no coverage. Building those is the exercise -- see
// ../README.md.

module tb;

  import uvm_pkg::*;
  import rv_plic_test_pkg::*;
  `include "uvm_macros.svh"

  logic clk, rst_n;

  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  // ---------------------------------------------------------------------
  // DUT tie-offs.
  //   tl_i        -> drive from a TL-UL host agent (hw/dv/sv/tl_agent)
  //   intr_src_i  -> the stimulus that matters: assert sources, then check
  //                  irq_o / irq_id_o against the programmed priorities and
  //                  thresholds. Tied to 0 here so nothing fires.
  //   irq_id_o    -> note this is an UNPACKED array, one entry per target.
  // ---------------------------------------------------------------------
  localparam int NumSrc    = rv_plic_reg_pkg::NumSrc;
  localparam int NumTarget = rv_plic_reg_pkg::NumTarget;
  localparam int SRCW      = $clog2(NumSrc);

  tlul_pkg::tl_h2d_t tl_i = tlul_pkg::TL_H2D_DEFAULT;
  tlul_pkg::tl_d2h_t tl_o;

  logic [NumSrc-1:0] intr_src_i = '0;

  prim_alert_pkg::alert_rx_t [rv_plic_reg_pkg::NumAlerts-1:0] alert_rx_i =
      '{default: prim_alert_pkg::ALERT_RX_DEFAULT};
  prim_alert_pkg::alert_tx_t [rv_plic_reg_pkg::NumAlerts-1:0] alert_tx_o;

  logic [NumTarget-1:0] irq_o;
  logic [SRCW-1:0]      irq_id_o [NumTarget];
  logic [NumTarget-1:0] msip_o;

  rv_plic dut (
    .clk_i  (clk),
    .rst_ni (rst_n),

    .tl_i (tl_i),
    .tl_o (tl_o),

    .intr_src_i (intr_src_i),

    .alert_rx_i (alert_rx_i),
    .alert_tx_o (alert_tx_o),

    .irq_o    (irq_o),
    .irq_id_o (irq_id_o),
    .msip_o   (msip_o)
  );

  tb_clk_if clk_if (.clk(clk), .rst_n(rst_n));

  initial begin
    uvm_config_db#(virtual tb_clk_if)::set(null, "*", "clk_if", clk_if);
    run_test();
  end

  initial begin
    #1ms;
    `uvm_fatal("TB", "timeout -- simulation ran for 1ms with no test completion")
  end

endmodule
