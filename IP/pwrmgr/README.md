# pwrmgr

> ⚠️ **This README is auto-generated** by `IP/scripts/gen_readme.py` and
> contains only facts extracted from the RTL and the upstream docs. It has
> **not** been curated with spec analysis. For examples of what a curated
> IP page looks like, see [`../uart/README.md`](../uart/README.md) or
> [`../rv_plic/README.md`](../rv_plic/README.md). Improving this file as you
> read the spec is a legitimate part of the exercise.

| | |
|---|---|
| **Tier** | advanced — Sleep/wake FSM across power domains |
| **Source** | `vendor/opentitan/hw/top_earlgrey/ip_autogen/pwrmgr/` @ `365c167e` |
| **Top module** | `pwrmgr` (`rtl/pwrmgr.sv`) |
| **RTL files** | 15 (including 6 externally-owned packages) |
| **DUT ports** | 38 |
| **Bus** | TL-UL device |
| **Interrupts** | 1 |
| **Clock domains** | 4 (`clk_slow_i`, `clk_i`, `clk_lc_i`, `clk_esc_i`) |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

> ⚠️ **Generated IP.** The upstream source of truth is the template at
> `hw/ip_templates/pwrmgr/`, instantiated for Earl Grey. What is copied here
> is the *generated Earl Grey instance*, which is what you want — it matches
> the chip the SoC track verifies. Do not look for it under `hw/ip/`.

---

## External dependencies

This IP references packages owned by *other* IPs, so they are copied into
`rtl/` and listed first in `rtl/files.f`:

| Package | From |
|---|---|
| `lc_ctrl_state_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv` |
| `lc_ctrl_reg_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv` |
| `ibex_pkg.sv` | `hw/vendor/lowrisc_ibex/rtl/ibex_pkg.sv` |
| `rv_core_ibex_pkg.sv` | `hw/ip/rv_core_ibex/rtl/rv_core_ibex_pkg.sv` |
| `rom_ctrl_pkg.sv` | `hw/ip/rom_ctrl/rtl/rom_ctrl_pkg.sv` |
| `lc_ctrl_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv` |

They are deliberately **not** in `IP/common/` — that carries what *every*
IP needs, not what *any* IP might need. See
[`../common/README.md`](../common/README.md). Resolved automatically by
`scripts/resolve_deps.py`.

---

## Interfaces

| Group | Present |
|---|---|
| Clock/reset | `clk_slow_i`, `clk_i`, `clk_lc_i`, `clk_esc_i` |
| TL-UL bus | `tl_i`, `tl_o` |
| Chip IO (`cio_*`) | 0 port(s) — none |
| Interrupts | `intr_wakeup_o` |
| Alerts | yes |
| RACL | — none |

Full port list with types: `verification/tb/tb.sv`, or `docs/interfaces.md`.

---

## Documentation

| File | Contents |
|---|---|
| [`docs/theory_of_operation.md`](docs/theory_of_operation.md) | How it works -- start here |
| [`docs/registers.md`](docs/registers.md) | Every register and field |
| [`docs/interfaces.md`](docs/interfaces.md) | Port list and parameters |
| [`docs/programmers_guide.md`](docs/programmers_guide.md) | Expected software sequences |
| [`docs/checklist.md`](docs/checklist.md) | Upstream's sign-off checklist |
| [`docs/pwrmgr.hjson`](docs/pwrmgr.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/pwrmgr_connectivity.svg`](docs/pwrmgr_connectivity.svg) | Diagram |
| [`docs/pwrmgr_fsms.svg`](docs/pwrmgr_fsms.svg) | Diagram |

Online: https://opentitan.org/book/hw/top_earlgrey/ip_autogen/pwrmgr/

> These track upstream HEAD, not our pinned commit. For exact behaviour
> always read the local `docs/` and the RTL.

---

## Getting started

```bash
source scripts/activate_env.sh
cd IP/pwrmgr/sim
./run_compile.sh          # elaborate + run the do-nothing test
```

Then follow the five steps in [`verification/README.md`](verification/README.md).
Your first real deliverable is `verification/testplan.md`, written from
`docs/theory_of_operation.md` — not from this file.
