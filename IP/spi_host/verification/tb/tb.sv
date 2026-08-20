// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// spi_host -- COMPILE-CHECK TESTBENCH
//
// A skeleton, not a verification environment. It proves the spi_host RTL and
// its dependencies elaborate and a UVM test can start and finish. No agent,
// no scoreboard, no RAL, no coverage. Building those is the exercise -- see
// ../README.md.

module tb;

  import uvm_pkg::*;
  import spi_host_test_pkg::*;
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
  //   tl_i           -> drive from a TL-UL host agent (hw/dv/sv/tl_agent)
  //   cio_sd_i[3:0]  -> the SPI data lines. Four of them because this IP
  //                     supports dual and quad modes, not just standard MISO.
  //                     A real TB needs an agent that models all three widths.
  //   passthrough_i  -> the spi_device passthrough path. This is why this IP
  //                     needs spi_device_pkg -- see rtl/files.f.
  // ---------------------------------------------------------------------
  localparam int NumCS = 1;   // matches the module default

  tlul_pkg::tl_h2d_t tl_i = tlul_pkg::TL_H2D_DEFAULT;
  tlul_pkg::tl_d2h_t tl_o;

  prim_alert_pkg::alert_rx_t [spi_host_reg_pkg::NumAlerts-1:0] alert_rx_i =
      '{default: prim_alert_pkg::ALERT_RX_DEFAULT};
  prim_alert_pkg::alert_tx_t [spi_host_reg_pkg::NumAlerts-1:0] alert_tx_o;

  top_racl_pkg::racl_policy_vec_t racl_policies_i =
      top_racl_pkg::RACL_POLICY_VEC_DEFAULT;
  top_racl_pkg::racl_error_log_t  racl_error_o;

  logic             cio_sck_o;
  logic             cio_sck_en_o;
  logic [NumCS-1:0] cio_csb_o;
  logic [NumCS-1:0] cio_csb_en_o;
  logic [3:0]       cio_sd_o;
  logic [3:0]       cio_sd_en_o;
  logic [3:0]       cio_sd_i = '0;

  spi_device_pkg::passthrough_req_t passthrough_i = '0;
  spi_device_pkg::passthrough_rsp_t passthrough_o;

  logic lsio_trigger_o;
  logic intr_error_o;
  logic intr_spi_event_o;

  spi_host #(
    .NumCS (NumCS)
  ) dut (
    .clk_i  (clk),
    .rst_ni (rst_n),

    .tl_i (tl_i),
    .tl_o (tl_o),

    .alert_rx_i (alert_rx_i),
    .alert_tx_o (alert_tx_o),

    .racl_policies_i (racl_policies_i),
    .racl_error_o    (racl_error_o),

    .cio_sck_o    (cio_sck_o),
    .cio_sck_en_o (cio_sck_en_o),
    .cio_csb_o    (cio_csb_o),
    .cio_csb_en_o (cio_csb_en_o),
    .cio_sd_o     (cio_sd_o),
    .cio_sd_en_o  (cio_sd_en_o),
    .cio_sd_i     (cio_sd_i),

    .passthrough_i (passthrough_i),
    .passthrough_o (passthrough_o),

    .lsio_trigger_o (lsio_trigger_o),

    .intr_error_o     (intr_error_o),
    .intr_spi_event_o (intr_spi_event_o)
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
