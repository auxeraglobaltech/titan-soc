# spi_host

SPI controller supporting standard, dual and quad width, all four SPI modes,
multiple chip selects, and a passthrough path that lets `spi_device` forward
traffic straight through to an external flash.

| | |
|---|---|
| **Tier** | Intermediate/advanced — three data widths, four clock modes, a segmented command queue |
| **Source** | `vendor/opentitan/hw/ip/spi_host/` @ `365c167e` |
| **Top module** | `spi_host` (`rtl/spi_host.sv`) |
| **Base address in Earl Grey** | `0x4030_0000` (spi_host0), `0x4031_0000` (spi_host1) |
| **Compile check** | 🔲 unverified |
| **Environment built** | 🔲 not started |

---

## An external dependency worth understanding

`spi_host` has a **passthrough** port typed `spi_device_pkg::passthrough_req_t`
— so it will not compile without `spi_device`'s packages, even though
`spi_device` is a different IP.

Those two files are copied into `rtl/` and listed first in `rtl/files.f`:

```
spi_device_reg_pkg.sv   <- hw/ip/spi_device/rtl/
spi_device_pkg.sv       <- hw/ip/spi_device/rtl/
```

They are deliberately **not** in `IP/common/`. The rule for this tree is that
`common/` carries what *every* IP needs, not what *any* IP might need — see
[`../common/README.md`](../common/README.md). When you scaffold an IP with a
cross-IP dependency, use `new_ip.sh --extra-rtl <path>`.

---

## Interfaces

| Port group | Signals | Notes |
|---|---|---|
| Clock/reset | `clk_i`, `rst_ni` | |
| Bus | `tl_i`, `tl_o` | TL-UL device |
| SPI | `cio_sck_o`, `cio_csb_o[NumCS-1:0]`, `cio_sd_o[3:0]`, `cio_sd_en_o[3:0]`, `cio_sd_i[3:0]` | **Four** data lines — quad mode, not just MISO/MOSI |
| Passthrough | `passthrough_i`, `passthrough_o` | From `spi_device` |
| Interrupts | `intr_error_o`, `intr_spi_event_o` | Only two, but each aggregates many causes via `ERROR_STATUS` / `EVENT_ENABLE` |
| Alerts | `alert_rx_i`, `alert_tx_o` | `NumAlerts = 1` |
| RACL | `racl_policies_i`, `racl_error_o` | Includes per-window policies for RXDATA/TXDATA |

Parameter: `NumCS = 1` by default (this TB uses the default).

---

## Documentation

`docs/theory_of_operation.md`, `docs/registers.md`, `docs/interfaces.md`,
`docs/programmers_guide.md`, `docs/spi_host.hjson` (**generate your RAL from
this**).

Online: https://opentitan.org/book/hw/ip/spi_host/ · https://lowrisc.org/peripheral-ip/

---

## Things this IP will make you think about

- **CPOL/CPHA.** Four combinations of clock polarity and phase. Every data test
  should run in all four — sampling on the wrong edge is the classic SPI bug
  and it only shows in two of the four modes.
- **Width modes.** Standard (1 bit), dual (2), quad (4). Your agent must decode
  all three, and the direction of `cio_sd` flips per segment.
- **Segments.** A command is a *queue* of segments, each with its own width and
  direction. Multi-segment commands with mixed widths are the real workload —
  and where the shift register and byte-select logic get interesting.
- **CSB timing.** Setup and hold around chip select, and the inter-command idle
  gap. Programmable, so measure against what was programmed.
- **Clock divider.** `CONFIGOPTS.CLKDIV` sets SCK frequency. Check the extremes,
  including divide-by-zero if the spec allows it.
- **FIFOs and stalls.** TX underflow and RX overflow mid-command — what does
  the FSM do, and does it recover?
- **The two interrupts.** Both are aggregates. Enumerate every cause bit and
  prove each one independently sets and clears.
- **Passthrough.** Traffic from `spi_device` bypasses the command queue. Lower
  priority than getting host mode solid, but do not forget it exists.

Get a single-segment standard-mode byte working end to end first — that alone
requires the agent, RAL, scoreboard and CSB timing to all be right.

Upstream's testplan is at
`vendor/opentitan/hw/ip/spi_host/data/spi_host_testplan.hjson` — deliberately
not copied. Write yours first, then diff.
