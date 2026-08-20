// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// pwm -- COMPILE-CHECK TESTBENCH
//
// A skeleton, not a verification environment. It proves the pwm RTL and its
// dependencies elaborate and a UVM test can start and finish. No agent, no
// scoreboard, no RAL, no coverage. Building those is the exercise -- see
// ../README.md.

module tb;

  import uvm_pkg::*;
  import pwm_test_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------------------
  // TWO clock domains. pwm has a bus clock and a separate, slower core clock
  // (in Earl Grey the core clock is the ~200 kHz AON clock). Getting the
  // ratio right matters: the duty-cycle logic counts in core-clock beats
  // while software programs it over the bus clock.
  // ---------------------------------------------------------------------
  logic clk, rst_n;              // bus clock, 100 MHz
  logic clk_core, rst_core_n;    // core clock, 25 MHz here (4:1, keeps sims short)

  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  initial begin
    clk_core = 1'b0;
    forever #20ns clk_core = ~clk_core;
  end

  initial begin
    rst_n      = 1'b0;
    rst_core_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n      = 1'b1;
    rst_core_n = 1'b1;
  end

  // ---------------------------------------------------------------------
  // DUT tie-offs.
  //   tl_i       -> drive from a TL-UL host agent (hw/dv/sv/tl_agent)
  //   cio_pwm_o  -> sample and measure period / duty cycle / phase
  // ---------------------------------------------------------------------
  localparam int NOutputs = pwm_reg_pkg::NOutputs;

  tlul_pkg::tl_h2d_t tl_i = tlul_pkg::TL_H2D_DEFAULT;
  tlul_pkg::tl_d2h_t tl_o;

  prim_alert_pkg::alert_rx_t [pwm_reg_pkg::NumAlerts-1:0] alert_rx_i =
      '{default: prim_alert_pkg::ALERT_RX_DEFAULT};
  prim_alert_pkg::alert_tx_t [pwm_reg_pkg::NumAlerts-1:0] alert_tx_o;

  top_racl_pkg::racl_policy_vec_t racl_policies_i =
      top_racl_pkg::RACL_POLICY_VEC_DEFAULT;
  top_racl_pkg::racl_error_log_t  racl_error_o;

  logic [NOutputs-1:0] cio_pwm_o;
  logic [NOutputs-1:0] cio_pwm_en_o;

  pwm dut (
    .clk_i       (clk),
    .rst_ni      (rst_n),
    .clk_core_i  (clk_core),
    .rst_core_ni (rst_core_n),

    .tl_i (tl_i),
    .tl_o (tl_o),

    .alert_rx_i (alert_rx_i),
    .alert_tx_o (alert_tx_o),

    .racl_policies_i (racl_policies_i),
    .racl_error_o    (racl_error_o),

    .cio_pwm_o    (cio_pwm_o),
    .cio_pwm_en_o (cio_pwm_en_o)
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
