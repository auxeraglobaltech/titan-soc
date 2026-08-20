// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// uart -- COMPILE-CHECK TESTBENCH
//
// This is a skeleton, not a verification environment. It exists to prove one
// thing: that the uart RTL and its dependencies elaborate cleanly and a UVM
// test can start and finish.
//
// It has no agent, no driver, no monitor, no scoreboard, no RAL, no coverage.
// The DUT's inputs are tied to constants -- nothing stimulates it. Building
// what is missing is the exercise; see ../README.md.
//
// The one thing worth keeping when you replace this file: the DUT
// instantiation and the clock/reset generation below are correct as written.

module tb;

  import uvm_pkg::*;
  import uart_test_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------------------
  // Clock and reset. 100 MHz, matching the Earl Grey peripheral clock.
  // ---------------------------------------------------------------------
  logic clk;
  logic rst_n;

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
  //
  // TODO(trainee): every one of these is a place a real TB plugs in.
  //   tl_i        -> drive from a TL-UL host agent (hw/dv/sv/tl_agent)
  //   cio_rx_i    -> drive from a UART agent; check cio_tx_o against it
  //   intr_*_o    -> sample into an interrupt monitor / scoreboard
  //   alert_tx_o  -> check against an alert receiver
  // ---------------------------------------------------------------------
  tlul_pkg::tl_h2d_t tl_i = tlul_pkg::TL_H2D_DEFAULT;
  tlul_pkg::tl_d2h_t tl_o;

  prim_alert_pkg::alert_rx_t [uart_reg_pkg::NumAlerts-1:0] alert_rx_i =
      '{default: prim_alert_pkg::ALERT_RX_DEFAULT};
  prim_alert_pkg::alert_tx_t [uart_reg_pkg::NumAlerts-1:0] alert_tx_o;

  top_racl_pkg::racl_policy_vec_t racl_policies_i =
      top_racl_pkg::RACL_POLICY_VEC_DEFAULT;
  top_racl_pkg::racl_error_log_t  racl_error_o;

  logic cio_rx_i = 1'b1;   // UART idle line is high
  logic cio_tx_o;
  logic cio_tx_en_o;
  logic lsio_trigger_o;

  logic intr_tx_watermark_o;
  logic intr_tx_empty_o;
  logic intr_rx_watermark_o;
  logic intr_tx_done_o;
  logic intr_rx_overflow_o;
  logic intr_rx_frame_err_o;
  logic intr_rx_break_err_o;
  logic intr_rx_timeout_o;
  logic intr_rx_parity_err_o;

  // ---------------------------------------------------------------------
  // DUT
  // ---------------------------------------------------------------------
  uart dut (
    .clk_i  (clk),
    .rst_ni (rst_n),

    .tl_i   (tl_i),
    .tl_o   (tl_o),

    .alert_rx_i (alert_rx_i),
    .alert_tx_o (alert_tx_o),

    .racl_policies_i (racl_policies_i),
    .racl_error_o    (racl_error_o),

    .lsio_trigger_o (lsio_trigger_o),

    .cio_rx_i    (cio_rx_i),
    .cio_tx_o    (cio_tx_o),
    .cio_tx_en_o (cio_tx_en_o),

    .intr_tx_watermark_o  (intr_tx_watermark_o),
    .intr_tx_empty_o      (intr_tx_empty_o),
    .intr_rx_watermark_o  (intr_rx_watermark_o),
    .intr_tx_done_o       (intr_tx_done_o),
    .intr_rx_overflow_o   (intr_rx_overflow_o),
    .intr_rx_frame_err_o  (intr_rx_frame_err_o),
    .intr_rx_break_err_o  (intr_rx_break_err_o),
    .intr_rx_timeout_o    (intr_rx_timeout_o),
    .intr_rx_parity_err_o (intr_rx_parity_err_o)
  );

  // ---------------------------------------------------------------------
  // UVM entry. The clock handle is published so the base test can wait on
  // edges without reaching up into the hierarchy by name.
  // ---------------------------------------------------------------------
  tb_clk_if clk_if (.clk(clk), .rst_n(rst_n));

  initial begin
    uvm_config_db#(virtual tb_clk_if)::set(null, "*", "clk_if", clk_if);
    run_test();
  end

  // Safety net: never let a broken test hang the regression.
  initial begin
    #1ms;
    `uvm_fatal("TB", "timeout -- simulation ran for 1ms with no test completion")
  end

endmodule
