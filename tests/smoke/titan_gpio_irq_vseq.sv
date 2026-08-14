// titan-soc trainee vseq — INT-3: GPIO interrupt on input edge.
//
// Paired with sw/trainee/gpio_irq_test.c. Read that file first: it documents
// the handshake this sequence implements the other half of.
//
// Registered via the package re-open mechanism (overlay/titan_vseq_extras.sv)
// and selected by `uvm_test_seq: titan_gpio_irq_vseq` in
// overlay/titan_sim_cfg.hjson.
//
// Division of labour: the SW side owns all the checking (pin ID, INTR_STATE,
// polarity, IRQ count) and reports PASS/FAIL through the status word. This
// sequence only has to produce clean, well-spaced edges and not race the SW.

class titan_gpio_irq_vseq extends chip_sw_base_vseq;
  `uvm_object_utils(titan_gpio_irq_vseq)
  `uvm_object_new

  // MUST match kNumTestPins in sw/trainee/gpio_irq_test.c. There is no
  // compile-time link between the two, so changing one means changing the
  // other. (Upgrade path: look the value up with sw_symbol_get_addr_size()
  // the way chip_sw_gpio_smoke_vseq does for kGpioVals.)
  localparam int NUM_TEST_PINS = 4;

  localparam bit [NUM_GPIOS-1:0] TEST_PIN_MASK = (1 << NUM_TEST_PINS) - 1;

  localparam uint TIMEOUT_NS = 2_000_000;

  // Cycles to allow the SW to arm its interrupts after we take the pins low.
  // Must cover kHandshakeSettleUsec (50us) in gpio_irq_test.c PLUS the time
  // to program the noise filter, trigger type, INTR_ENABLE, the PLIC range
  // and the Ibex IRQ enables. At 100MHz, 10k cycles is ~100us -- roughly 2x
  // the SW settle time, so the SW is always armed before the first edge.
  localparam int ARM_DELAY_CLKS = 10000;

  virtual task body();
    super.body();

    // Wait until the TEST ROM has handed off to our C payload.
    `DV_WAIT(cfg.sw_test_status_vif.sw_test_status == SwTestStatusInTest)
    `uvm_info(`gfn, "SW reached InTest", UVM_LOW)

    gpio_irq_handshake();
    drive_edges(.rising(1'b1));
    drive_edges(.rising(1'b0));

    `uvm_info(`gfn, "All edges driven; SW now checks the IRQ count", UVM_LOW)
  endtask

  // Three-step handshake, mirroring test_main() in gpio_irq_test.c:
  //   1. SW drives the test pins high as outputs  -> "SW is alive"
  //   2. SW releases them (they go to z)          -> "pins are yours"
  //   3. we drive ALL pins low; SW waits a fixed
  //      settle time, then arms interrupts        -> "TB has the pins"
  //
  // Step 3 is a timed handoff, not a polled one: the SW cannot read DATA_IN
  // while the pads float without tripping the TL-UL dKnown assertions
  // (quirk #14), so it spins kHandshakeSettleUsec instead. ARM_DELAY_CLKS
  // must stay comfortably longer than that spin.
  virtual task gpio_irq_handshake();
    // Make sure we are not driving anything while the SW owns the pins.
    cfg.chip_vif.gpios_if.drive_en({NUM_GPIOS{1'b0}});

    `uvm_info(`gfn, "Waiting for SW to drive test pins high", UVM_LOW)
    `DV_SPINWAIT(wait(cfg.chip_vif.gpios_if.pins[NUM_TEST_PINS-1:0] ===
                      TEST_PIN_MASK[NUM_TEST_PINS-1:0]);,
                 "Timed out waiting for SW to drive test pins high",
                 TIMEOUT_NS, `gfn)

    `uvm_info(`gfn, "Waiting for SW to release test pins", UVM_LOW)
    `DV_SPINWAIT(wait(cfg.chip_vif.gpios_if.pins[NUM_TEST_PINS-1:0] ===
                      {NUM_TEST_PINS{1'bz}});,
                 "Timed out waiting for SW to release test pins",
                 TIMEOUT_NS, `gfn)

    // Drive ALL NUM_GPIOS pins low, not just the 4 under test.
    //
    // This is not optional. The SW calls dif_gpio_read_all(), which reads the
    // whole 32-bit DATA_IN register, so a single floating pin puts an X in
    // the TL-UL read response and trips tlul_assert's dKnown_A /
    // dDataKnown_M. An earlier version drove only pins 0..3 and died at
    // 3248us on exactly that. Upstream chip_sw_gpio_vseq drives the full
    // mask for the same reason. See docs/XCELIUM_NOTES.md quirk #14.
    //
    // drive() asserts the output enable on every pin, which is what we want
    // here -- the SW has already released them, so there is no contention.
    `uvm_info(`gfn, "Driving all GPIO pins low", UVM_LOW)
    cfg.chip_vif.gpios_if.drive({NUM_GPIOS{1'b0}});

    // Give the SW time to settle and arm its interrupts before the first
    // edge arrives.
    cfg.chip_vif.cpu_clk_rst_if.wait_clks(ARM_DELAY_CLKS);
  endtask

  // Walks one edge across pins 0..NUM_TEST_PINS-1, in the order the SW
  // expects them. The gaps let the SW enter and leave its ISR before the
  // next edge lands - without them the SW would see a second pin pending in
  // INTR_STATE and fail its "exactly one pin" check.
  virtual task drive_edges(bit rising);
    `uvm_info(`gfn, $sformatf("Driving %s edges on pins 0..%0d",
                              rising ? "rising" : "falling", NUM_TEST_PINS - 1),
              UVM_LOW)
    for (int i = 0; i < NUM_TEST_PINS; i++) begin
      cfg.chip_vif.cpu_clk_rst_if.wait_clks($urandom_range(1100, 2000));
      cfg.chip_vif.gpios_if.drive_pin(i, rising);
      `uvm_info(`gfn, $sformatf("Drove pin %0d -> %0b", i, rising), UVM_HIGH)
    end
  endtask

endclass : titan_gpio_irq_vseq
