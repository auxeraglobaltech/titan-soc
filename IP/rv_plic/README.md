# rv_plic

RISC-V Platform-Level Interrupt Controller. Collects 186 interrupt sources,
applies a programmable priority to each, and raises a single external-interrupt
line to the Ibex core when any enabled source outranks the target's threshold.

| | |
|---|---|
| **Tier** | Advanced — no serial protocol, but deep combinational priority logic and a claim/complete handshake with strict ordering rules |
| **Source** | `vendor/opentitan/hw/top_earlgrey/ip_autogen/rv_plic/` @ `365c167e` |
| **Top module** | `rv_plic` (`rtl/rv_plic.sv`) |
| **Base address in Earl Grey** | `0x4800_0000` |
| **Sources / targets** | `NumSrc = 186`, `NumTarget = 1` |
| **Compile check** | 🔲 unverified |
| **Environment built** | 🔲 not started |

> ⚠️ Generated IP — template at `hw/ip_templates/rv_plic/`. `NumSrc` is derived
> from how many interrupts Earl Grey actually has, so this instance is
> chip-specific.

---

## Why this one is harder than it looks

There is no protocol to model and only one real output. The difficulty is that
**the correct answer is a priority computation over 186 inputs**, and your
scoreboard has to reproduce it exactly:

- Which source wins when several are pending at the same priority?
- What does `irq_id_o` read when nothing is pending?
- The **claim/complete** handshake: reading `CC0` claims the highest-priority
  pending interrupt and clears its pending bit; writing it back completes.
  Claiming out of order, completing an ID that was never claimed, or claiming
  twice without completing are all cases a real testplan covers.
- `LevelEdgeTrig` is a per-source parameter. Earl Grey sets it to all-zeros
  (level), and upstream notes edge-triggered CDC handling is **not fully
  implemented** — so treat edge mode as an RTL caveat, not just a test mode.

A model-based scoreboard is close to mandatory here. Writing 186 directed tests
is not a plan; randomising source assertion and predicting the winner is.

---

## Interfaces

| Port group | Signals | Notes |
|---|---|---|
| Clock/reset | `clk_i`, `rst_ni` | |
| Bus | `tl_i`, `tl_o` | TL-UL device |
| Sources | `intr_src_i[185:0]` | One per peripheral interrupt in the chip |
| Target IRQ | `irq_o[0:0]`, `irq_id_o[0]` | To the Ibex external-interrupt input. **`irq_id_o` is an unpacked array**, one entry per target |
| Software IRQ | `msip_o[0:0]` | RISC-V machine software interrupt |
| Alerts | `alert_rx_i`, `alert_tx_o` | `NumAlerts = 1` |

Note: **no RACL ports** on this IP, unlike the peripherals.

---

## Documentation

`docs/theory_of_operation.md`, `docs/registers.md`, `docs/interfaces.md`,
`docs/rv_plic.hjson` (**generate your RAL from this** — with 186 sources the
register file is large and hand-writing accesses is not viable).

Online:
- https://opentitan.org/book/hw/top_earlgrey/ip_autogen/rv_plic/
- RISC-V PLIC spec — https://github.com/riscv/riscv-plic-spec

---

## Things this IP will make you think about

- **Priority ordering.** Assert N random sources with random priorities;
  predict the winner. Then make several tie on priority and check the
  tie-break rule matches the spec (lowest ID wins).
- **Threshold.** A source at or below the target threshold must not raise
  `irq_o`. Boundary: priority exactly equal to threshold.
- **Claim/complete.** Full handshake, including the illegal sequences above.
- **Pending vs enabled.** A disabled source still sets its pending bit. Enable
  it later and the interrupt should fire without re-asserting the source.
- **Level vs edge.** Level sources stay pending while the input is high.
- **Register array walking.** `IE`, `IP`, `PRIO` are wide arrays — a
  CSR-walking test over all 186 finds RAL and address-decode bugs cheaply.

This is the same PLIC the SoC track's `titan_sw_gpio_irq_test` exercises from
the software side — a good IP to pick if you have already done that test and
want to see the block underneath it.

Upstream's testplan is at
`vendor/opentitan/hw/top_earlgrey/ip_autogen/rv_plic/data/rv_plic_testplan.hjson`
— deliberately not copied. Write yours first, then diff.
