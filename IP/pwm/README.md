# pwm

Six independent pulse-width-modulated outputs with programmable duty cycle,
phase, blink and heartbeat modes. Runs from a slow always-on clock so it keeps
driving LEDs while the chip sleeps.

| | |
|---|---|
| **Tier** | Starter — small register file, no bus protocol on the output side |
| **Source** | `vendor/opentitan/hw/top_earlgrey/ip_autogen/pwm/` @ `365c167e` |
| **Top module** | `pwm` (`rtl/pwm.sv`) |
| **Base address in Earl Grey** | `0x4045_0000` (`pwm_aon`) |
| **Outputs** | `NOutputs = 6` |
| **Compile check** | 🔲 unverified |
| **Environment built** | 🔲 not started |

> ⚠️ Generated IP — the template is `hw/ip_templates/pwm/`, instantiated for
> Earl Grey. Not under `hw/ip/`.

---

## The thing that makes this IP interesting

**It has two clock domains.** `clk_i`/`rst_ni` is the 100 MHz bus clock that
software uses; `clk_core_i`/`rst_core_ni` is the slow always-on clock (~200 kHz
in Earl Grey) that the counters actually run on.

Everything hard about verifying this IP follows from that:

- Register writes cross from bus to core domain. What happens if software
  updates the duty cycle mid-period?
- Your scoreboard must count in **core-clock beats**, not bus cycles.
- A slow core clock makes sims long. The TB here uses a 4:1 ratio to keep the
  compile check quick — a real testplan should cover realistic ratios *and*
  the degenerate 1:1 case.

---

## Interfaces

| Port group | Signals | Notes |
|---|---|---|
| Bus clock | `clk_i`, `rst_ni` | 100 MHz |
| Core clock | `clk_core_i`, `rst_core_ni` | Slow AON clock — the counters run here |
| Bus | `tl_i`, `tl_o` | TL-UL device |
| Outputs | `cio_pwm_o[5:0]`, `cio_pwm_en_o[5:0]` | Six channels |
| Alerts | `alert_rx_i`, `alert_tx_o` | `NumAlerts = 1` |
| RACL | `racl_policies_i`, `racl_error_o` | Disabled by default |

Parameters: `PhaseCntDw = 16`, `BeatCntDw = 27`, plus the usual alert/RACL set.

Note there are **no interrupts** — unusual for a comportable IP, and it makes
this a gentler first target.

---

## Documentation

`docs/theory_of_operation.md`, `docs/registers.md`, `docs/interfaces.md`,
`docs/programmers_guide.md`, and `docs/pwm.hjson` (**generate your RAL from
this**).

Online: https://opentitan.org/book/hw/ip/pwm/ · https://lowrisc.org/peripheral-ip/

---

## Things this IP will make you think about

- **Duty cycle boundaries.** 0% and 100% are the classic bug sites. Does 0%
  actually hold the line low, or emit a one-beat glitch?
- **Phase offset.** Channels can be phase-shifted relative to each other.
  Measure the actual skew between two channels' rising edges.
- **Blink mode.** The channel alternates between two duty cycles on a timer.
  Check the dwell counts, and what happens when you switch modes mid-blink.
- **Heartbeat mode.** Duty ramps linearly between two values. The step size and
  the turnaround at each end are worth their own tests.
- **CDC.** Program a new duty cycle and check the output changes at a period
  boundary, not immediately — and never emits a runt pulse.
- **Clock ratio.** Re-run your whole suite at several `clk_i:clk_core_i`
  ratios. This is where CDC bugs actually show up.

Upstream's testplan is at
`vendor/opentitan/hw/top_earlgrey/ip_autogen/pwm/data/pwm_testplan.hjson` —
deliberately not copied. Write yours first, then diff.
