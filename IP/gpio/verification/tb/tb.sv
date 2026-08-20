// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// gpio -- COMPILE-CHECK TESTBENCH
//
// This is a skeleton, not a verification environment. It exists to prove one
// thing: that the gpio RTL and its dependencies elaborate cleanly and a UVM
// test can start and finish.
//
// It has no agent, no driver, no monitor, no scoreboard, no RAL, no coverage.
// The DUT's inputs are tied to constants -- nothing stimulates it. Building
// what is missing is the exercise; see ../README.md.

module tb;

  import uvm_pkg::*;
  import gpio_test_pkg::*;
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
  //   tl_i         -> drive from a TL-UL host agent (hw/dv/sv/tl_agent)
  //   cio_gpio_i   -> drive from a pins_if; check cio_gpio_o / _en_o back
  //   intr_gpio_o  -> sample into an interrupt monitor / scoreboard
  //   strap_en_i   -> pulse it and check sampled_straps_o
  //
  // NOTE: cio_gpio_i is tied to a constant 0 here rather than left floating.
  // A floating input would propagate X through the input filters and the
  // register file. The chip-level track hit exactly this and lost a debug
  // cycle to it (see docs/XCELIUM_NOTES.md quirk #14).
  // ---------------------------------------------------------------------
  localparam int NumIOs = gpio_reg_pkg::NumIOs;

  tlul_pkg::tl_h2d_t tl_i = tlul_pkg::TL_H2D_DEFAULT;
  tlul_pkg::tl_d2h_t tl_o;

  prim_alert_pkg::alert_rx_t [gpio_reg_pkg::NumAlerts-1:0] alert_rx_i =
      '{default: prim_alert_pkg::ALERT_RX_DEFAULT};
  prim_alert_pkg::alert_tx_t [gpio_reg_pkg::NumAlerts-1:0] alert_tx_o;

  top_racl_pkg::racl_policy_vec_t racl_policies_i =
      top_racl_pkg::RACL_POLICY_VEC_DEFAULT;
  top_racl_pkg::racl_error_log_t  racl_error_o;

  logic                 strap_en_i = 1'b0;
  gpio_pkg::gpio_straps_t sampled_straps_o;

  logic [NumIOs-1:0] cio_gpio_i = '0;
  logic [NumIOs-1:0] cio_gpio_o;
  logic [NumIOs-1:0] cio_gpio_en_o;
  logic [NumIOs-1:0] intr_gpio_o;

  // ---------------------------------------------------------------------
  // DUT
  // ---------------------------------------------------------------------
  gpio dut (
    .clk_i  (clk),
    .rst_ni (rst_n),

    .strap_en_i       (strap_en_i),
    .sampled_straps_o (sampled_straps_o),

    .tl_i (tl_i),
    .tl_o (tl_o),

    .intr_gpio_o (intr_gpio_o),

    .alert_rx_i (alert_rx_i),
    .alert_tx_o (alert_tx_o),

    .racl_policies_i (racl_policies_i),
    .racl_error_o    (racl_error_o),

    .cio_gpio_i    (cio_gpio_i),
    .cio_gpio_o    (cio_gpio_o),
    .cio_gpio_en_o (cio_gpio_en_o)
  );

  // ---------------------------------------------------------------------
  // UVM entry.
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
