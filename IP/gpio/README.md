# gpio

32 general-purpose I/O pins with per-pin direction control, masked atomic
writes, programmable input noise filtering, per-pin interrupts on four trigger
types, and hardware strap sampling.

| | |
|---|---|
| **Tier** | Starter — register-mapped, one pin interface, no protocol |
| **Source** | `vendor/opentitan/hw/top_earlgrey/ip_autogen/gpio/` @ `365c167e` |
| **Top module** | `gpio` (`rtl/gpio.sv`) |
| **Bus** | TL-UL device |
| **Base address in Earl Grey** | `0x4004_0000` |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

> ⚠️ **This IP is generated, not hand-written.** The source of truth upstream is
> the template at `hw/ip_templates/gpio/`, instantiated for Earl Grey into
> `hw/top_earlgrey/ip_autogen/gpio/` with `NumIOs = 32`. What is copied here is
> the *generated Earl Grey instance* — which is what you want, since it matches
> the chip the SoC track verifies. Do not expect to find it under `hw/ip/`.

---

## Interfaces

| Port group | Signals | Notes |
|---|---|---|
| Clock/reset | `clk_i`, `rst_ni` | |
| Bus | `tl_i`, `tl_o` | TL-UL device |
| GPIO | `cio_gpio_i`, `cio_gpio_o`, `cio_gpio_en_o` | 32 bits each; `_en_o` is per-pin output enable |
| Interrupts | `intr_gpio_o[31:0]` | One per pin |
| Straps | `strap_en_i`, `sampled_straps_o` | Sample pin state at boot for hardware configuration |
| Alerts | `alert_rx_i`, `alert_tx_o` | `NumAlerts = 1` — fatal fault |
| RACL | `racl_policies_i`, `racl_error_o` | Disabled by default |

Parameters: `GpioAsHwStrapsEn` (strap sampling), `GpioAsyncOn` (2-stage input
synchronisers), `AlertAsyncOn`, `AlertSkewCycles`, `EnableRacl`.

---

## Documentation

| File | Contents |
|---|---|
| [`docs/theory_of_operation.md`](docs/theory_of_operation.md) | How it works — start here |
| [`docs/registers.md`](docs/registers.md) | Every register and field |
| [`docs/interfaces.md`](docs/interfaces.md) | Port list and parameters |
| [`docs/programmers_guide.md`](docs/programmers_guide.md) | Expected SW sequences |
| [`docs/gpio.hjson`](docs/gpio.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/gpio_blockdiagram.svg`](docs/gpio_blockdiagram.svg), [`docs/gpio_output.svg`](docs/gpio_output.svg) | Diagrams |

Online:

- GPIO IP — https://opentitan.org/book/hw/ip/gpio/
- lowRISC peripheral IP — https://lowrisc.org/peripheral-ip/
- Comportability spec — https://opentitan.org/book/doc/contributing/hw/comportability/

---

## Things this IP will make you think about

- **Masked writes.** `MASKED_OUT_LOWER` / `MASKED_OUT_UPPER` let software set
  16 pins atomically using a mask in the upper half-word. Easy to get the
  half-word split wrong; easy for RTL to get the read-back wrong.
- **`DIRECT_OUT` vs masked.** Do they compose correctly, in either order?
- **Interrupt trigger types.** Rising, falling, high-level, low-level — all
  four are independently enabled *per pin*, and they can be enabled together.
  What happens when two trigger types match at once?
- **Input noise filter.** `CTRL_EN_INPUT_FILTER` requires a value stable for 16
  cycles. Prove a 15-cycle pulse is rejected and a 16-cycle one is not — an
  off-by-one here is a real bug class.
- **`DATA_IN` vs output loopback.** With a pin driven as an output, what does
  `DATA_IN` read?
- **Strap sampling.** `strap_en_i` should latch pin state exactly once. Does a
  second pulse re-sample? Should it?
- **Async synchronisers.** With `GpioAsyncOn = 1` there are two flops of
  latency on every input. Your scoreboard must model that delay or it will
  mismatch on every edge.

An easier starting point than uart: no protocol to model, and the checking is
mostly "did the pin go where the register said". Interrupt trigger-type
crossing is where the real coverage work is.

Upstream's own testplan is at
`vendor/opentitan/hw/top_earlgrey/ip_autogen/gpio/data/gpio_testplan.hjson` —
**deliberately not copied here.** Write yours first, then diff.
