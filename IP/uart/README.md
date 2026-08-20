# uart

Asynchronous serial transmitter/receiver. TX and RX FIFOs, a programmable
baud-rate generator, a line-break detector, an RX noise filter, and nine
interrupts.

| | |
|---|---|
| **Tier** | Intermediate — real serial protocol, FIFOs, many interrupts |
| **Source** | `vendor/opentitan/hw/ip/uart/` @ `365c167e` |
| **Top module** | `uart` (`rtl/uart.sv`) |
| **Bus** | TL-UL device |
| **Base address in Earl Grey** | `0x4000_0000` (uart0) |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

---

## Interfaces

| Port group | Signals | Notes |
|---|---|---|
| Clock/reset | `clk_i`, `rst_ni` | 100 MHz peripheral clock in Earl Grey |
| Bus | `tl_i`, `tl_o` | TL-UL device; reuse `hw/dv/sv/tl_agent` as host |
| Serial | `cio_rx_i`, `cio_tx_o`, `cio_tx_en_o` | Idle is **high**; `_en_o` is the pad output enable |
| Interrupts | 9 × `intr_*_o` | `tx_watermark`, `tx_empty`, `rx_watermark`, `tx_done`, `rx_overflow`, `rx_frame_err`, `rx_break_err`, `rx_timeout`, `rx_parity_err` |
| Alerts | `alert_rx_i`, `alert_tx_o` | `NumAlerts = 1` — fatal fault |
| RACL | `racl_policies_i`, `racl_error_o` | Disabled by default (`EnableRacl = 0`) |
| Other | `lsio_trigger_o` | Low-speed IO trigger, for the DMA |

Parameters worth knowing: `AlertAsyncOn`, `AlertSkewCycles`, `EnableRacl`,
`RaclErrorRsp`, `RaclPolicySelVec`.

---

## Documentation

Local, copied from upstream — read these first:

| File | Contents |
|---|---|
| [`docs/theory_of_operation.md`](docs/theory_of_operation.md) | How it works — start here |
| [`docs/registers.md`](docs/registers.md) | Every register and field |
| [`docs/interfaces.md`](docs/interfaces.md) | Port list and parameters |
| [`docs/programmers_guide.md`](docs/programmers_guide.md) | Expected SW sequences |
| [`docs/uart.hjson`](docs/uart.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/block_diagram.svg`](docs/block_diagram.svg) | Block diagram |
| [`docs/checklist.md`](docs/checklist.md) | Upstream's sign-off checklist |

Online (tracks upstream HEAD, not our pinned commit — use the local files for
exact behaviour):

- UART IP — https://opentitan.org/book/hw/ip/uart/
- lowRISC peripheral IP — https://lowrisc.org/peripheral-ip/
- Comportability spec (interrupts/alerts conventions) —
  https://opentitan.org/book/doc/contributing/hw/comportability/
- TileLink-UL — https://www.sifive.com/documentation/tilelink/tilelink-spec/

---

## Things this IP will make you think about

Good sources of testplan entries, in rough order of difficulty:

- **Baud rate.** `NCO` sets the bit period. What happens at the extremes? Does
  a mid-transfer `NCO` change corrupt the frame?
- **FIFO watermarks.** `tx_watermark` / `rx_watermark` fire at programmable
  levels. Are the boundaries off-by-one? Does the interrupt re-assert if the
  level is still crossed after an ack?
- **Overflow.** Fill RX without draining. `rx_overflow` should fire and data
  should be dropped predictably — which byte is lost?
- **Line errors.** Frame error, parity error, break detection. Injecting these
  needs an agent that can drive a *malformed* frame, not just a good one.
- **RX timeout.** Fires after an idle gap with a non-empty FIFO. Interaction
  with the watermark is a classic bug hiding place.
- **Noise filter.** `cio_rx_i` is filtered. Prove a glitch narrower than the
  filter is rejected and one wider is not.
- **Loopback modes.** System and line loopback in `CTRL`.

Upstream's own testplan is at
`vendor/opentitan/hw/ip/uart/data/uart_testplan.hjson` — **deliberately not
copied here.** Write yours first, then diff.
