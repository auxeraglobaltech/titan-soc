// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// i2c -- COMPILE-CHECK TESTBENCH
//
// A skeleton, not a verification environment. It proves the i2c RTL and its
// dependencies elaborate and a UVM test can start and finish. No agent, no
// scoreboard, no RAL, no coverage. Building those is the exercise -- see
// ../README.md.

module tb;

  import uvm_pkg::*;
  import i2c_test_pkg::*;
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
  //   tl_i               -> drive from a TL-UL host agent (hw/dv/sv/tl_agent)
  //   cio_scl_i/sda_i    -> I2C is OPEN DRAIN. A real TB models the wired-AND
  //                         of the bus: the line is high unless the DUT or an
  //                         agent pulls it low. Both are tied HIGH here (idle).
  //   ram_cfg_i          -> SRAM configuration for the FIFOs; '0 is fine.
  //   intr_*_o           -> 15 interrupts, the most of any IP in this tree.
  // ---------------------------------------------------------------------
  tlul_pkg::tl_h2d_t tl_i = tlul_pkg::TL_H2D_DEFAULT;
  tlul_pkg::tl_d2h_t tl_o;

  prim_ram_1p_pkg::ram_1p_cfg_t     ram_cfg_i = '0;
  prim_ram_1p_pkg::ram_1p_cfg_rsp_t ram_cfg_rsp_o;

  prim_alert_pkg::alert_rx_t [i2c_reg_pkg::NumAlerts-1:0] alert_rx_i =
      '{default: prim_alert_pkg::ALERT_RX_DEFAULT};
  prim_alert_pkg::alert_tx_t [i2c_reg_pkg::NumAlerts-1:0] alert_tx_o;

  top_racl_pkg::racl_policy_vec_t racl_policies_i =
      top_racl_pkg::RACL_POLICY_VEC_DEFAULT;
  top_racl_pkg::racl_error_log_t  racl_error_o;

  logic cio_scl_i = 1'b1;   // idle high (open drain, pulled up)
  logic cio_scl_o;
  logic cio_scl_en_o;
  logic cio_sda_i = 1'b1;   // idle high
  logic cio_sda_o;
  logic cio_sda_en_o;

  logic lsio_trigger_o;

  logic intr_fmt_threshold_o;
  logic intr_rx_threshold_o;
  logic intr_acq_threshold_o;
  logic intr_rx_overflow_o;
  logic intr_controller_halt_o;
  logic intr_scl_interference_o;
  logic intr_sda_interference_o;
  logic intr_stretch_timeout_o;
  logic intr_sda_unstable_o;
  logic intr_cmd_complete_o;
  logic intr_tx_stretch_o;
  logic intr_tx_threshold_o;
  logic intr_acq_stretch_o;
  logic intr_unexp_stop_o;
  logic intr_host_timeout_o;

  i2c dut (
    .clk_i  (clk),
    .rst_ni (rst_n),

    .ram_cfg_i     (ram_cfg_i),
    .ram_cfg_rsp_o (ram_cfg_rsp_o),

    .tl_i (tl_i),
    .tl_o (tl_o),

    .alert_rx_i (alert_rx_i),
    .alert_tx_o (alert_tx_o),

    .racl_policies_i (racl_policies_i),
    .racl_error_o    (racl_error_o),

    .cio_scl_i    (cio_scl_i),
    .cio_scl_o    (cio_scl_o),
    .cio_scl_en_o (cio_scl_en_o),
    .cio_sda_i    (cio_sda_i),
    .cio_sda_o    (cio_sda_o),
    .cio_sda_en_o (cio_sda_en_o),

    .lsio_trigger_o (lsio_trigger_o),

    .intr_fmt_threshold_o    (intr_fmt_threshold_o),
    .intr_rx_threshold_o     (intr_rx_threshold_o),
    .intr_acq_threshold_o    (intr_acq_threshold_o),
    .intr_rx_overflow_o      (intr_rx_overflow_o),
    .intr_controller_halt_o  (intr_controller_halt_o),
    .intr_scl_interference_o (intr_scl_interference_o),
    .intr_sda_interference_o (intr_sda_interference_o),
    .intr_stretch_timeout_o  (intr_stretch_timeout_o),
    .intr_sda_unstable_o     (intr_sda_unstable_o),
    .intr_cmd_complete_o     (intr_cmd_complete_o),
    .intr_tx_stretch_o       (intr_tx_stretch_o),
    .intr_tx_threshold_o     (intr_tx_threshold_o),
    .intr_acq_stretch_o      (intr_acq_stretch_o),
    .intr_unexp_stop_o       (intr_unexp_stop_o),
    .intr_host_timeout_o     (intr_host_timeout_o)
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
