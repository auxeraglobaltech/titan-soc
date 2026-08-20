# i2c

I2C controller *and* target in one IP — it can drive a bus as host, or respond
as a device, with programmable timing, clock stretching, and 15 interrupts.

| | |
|---|---|
| **Tier** | Intermediate/advanced — two full operating modes, open-drain bus, the most interrupts of any IP here |
| **Source** | `vendor/opentitan/hw/ip/i2c/` @ `365c167e` |
| **Top module** | `i2c` (`rtl/i2c.sv`) |
| **Base address in Earl Grey** | `0x4008_0000` (i2c0), `0x4009_0000` (i2c1), `0x400A_0000` (i2c2) |
| **Compile check** | 🔲 unverified |
| **Environment built** | 🔲 not started |

---

## The thing that catches people first

**I2C is open-drain.** `scl` and `sda` are never driven high — they are pulled
up, and any device on the bus can pull them low. The IP reflects this with
split `_i` / `_o` / `_en_o` signals per line.

Your TB must model the **wired-AND**: the line is high only when nobody is
pulling it down. Tie `cio_sda_i` straight to `cio_sda_o` and you will model a
bus that cannot work — no arbitration, no clock stretching, no ACK.

That single fact generates a large part of the testplan: arbitration loss,
clock stretching by a slow target, and SDA/SCL interference detection all
depend on somebody else pulling the line.

---

## Interfaces

| Port group | Signals | Notes |
|---|---|---|
| Clock/reset | `clk_i`, `rst_ni` | |
| Bus | `tl_i`, `tl_o` | TL-UL device |
| SRAM cfg | `ram_cfg_i`, `ram_cfg_rsp_o` | FIFO memory configuration; `'0` is fine for functional work |
| I2C | `cio_scl_i/o/en_o`, `cio_sda_i/o/en_o` | Open drain — see above |
| Interrupts | 15 × `intr_*_o` | `fmt_threshold`, `rx_threshold`, `acq_threshold`, `rx_overflow`, `controller_halt`, `scl_interference`, `sda_interference`, `stretch_timeout`, `sda_unstable`, `cmd_complete`, `tx_stretch`, `tx_threshold`, `acq_stretch`, `unexp_stop`, `host_timeout` |
| Alerts | `alert_rx_i`, `alert_tx_o` | `NumAlerts = 1` |
| RACL | `racl_policies_i`, `racl_error_o` | Disabled by default |
| Other | `lsio_trigger_o` | DMA trigger |

Parameter worth noting: `InputDelayCycles` — models input path delay, and is
exactly the kind of parameter that should be swept in a regression.

---

## Documentation

`docs/theory_of_operation.md`, `docs/registers.md`, `docs/interfaces.md`,
`docs/programmers_guide.md`, `docs/i2c.hjson` (**generate your RAL from this**).

Online: https://opentitan.org/book/hw/ip/i2c/ · https://lowrisc.org/peripheral-ip/
· NXP I2C spec (UM10204) — the authority on timing parameters.

---

## Things this IP will make you think about

- **Two modes.** Controller and target are almost separate designs sharing a
  register file. Plan them as two testplan sections, then a third for the
  interaction.
- **Timing parameters.** `TIMING0`–`TIMING4` set setup/hold/start/stop times.
  Measure the actual waveform against the programmed values — this is where a
  scoreboard earns its keep.
- **Standard/Fast/Fast-Plus modes.** Different timing envelopes; the spec gives
  minimums your TB should assert against.
- **Clock stretching.** A target holds `scl` low to delay the controller. Both
  directions need testing, plus `stretch_timeout`.
- **Arbitration loss.** Two controllers start together; the one that loses must
  back off cleanly mid-transfer.
- **ACK/NACK.** Address NACK, data NACK, and NACK on the last byte.
- **FIFO thresholds.** Four separate FIFOs (fmt, rx, tx, acq) each with a
  threshold interrupt. Boundary conditions on all four.
- **Unexpected STOP / bus errors.** `unexp_stop`, `sda_unstable`,
  `sda_interference`, `scl_interference` — malformed-traffic injection, which
  needs an agent that can deliberately violate the protocol.

Start with controller-mode single-byte write, get the scoreboard predicting the
waveform, then expand. Do not try to bring up both modes at once.

Upstream's testplan is at `vendor/opentitan/hw/ip/i2c/data/i2c_testplan.hjson`
— deliberately not copied. Write yours first, then diff.
