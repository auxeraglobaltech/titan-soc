# adc_ctrl

> ⚠️ **This README is auto-generated** by `IP/scripts/gen_readme.py` and
> contains only facts extracted from the RTL and the upstream docs. It has
> **not** been curated with spec analysis. For examples of what a curated
> IP page looks like, see [`../uart/README.md`](../uart/README.md) or
> [`../rv_plic/README.md`](../rv_plic/README.md). Improving this file as you
> read the spec is a legitimate part of the exercise.

| | |
|---|---|
| **Tier** | intermediate — Sampling FSM with filters and a wakeup path |
| **Source** | `vendor/opentitan/hw/ip/adc_ctrl/` @ `365c167e` |
| **Top module** | `adc_ctrl` (`rtl/adc_ctrl.sv`) |
| **RTL files** | 8 (including 1 externally-owned package) |
| **DUT ports** | 12 |
| **Bus** | TL-UL device |
| **Interrupts** | 1 |
| **Clock domains** | 2 (`clk_i`, `clk_aon_i`) |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

---

## External dependencies

This IP references packages owned by *other* IPs, so they are copied into
`rtl/` and listed first in `rtl/files.f`:

| Package | From |
|---|---|
| `ast_pkg.sv` | `hw/top_darjeeling/ip/ast/rtl/ast_pkg.sv` |

They are deliberately **not** in `IP/common/` — that carries what *every*
IP needs, not what *any* IP might need. See
[`../common/README.md`](../common/README.md). Resolved automatically by
`scripts/resolve_deps.py`.

---

## Interfaces

| Group | Present |
|---|---|
| Clock/reset | `clk_i`, `clk_aon_i` |
| TL-UL bus | `tl_i`, `tl_o` |
| Chip IO (`cio_*`) | 0 port(s) — none |
| Interrupts | `intr_match_pending_o` |
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
| [`docs/adc_ctrl.hjson`](docs/adc_ctrl.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/adc_overview.svg`](docs/adc_overview.svg) | Diagram |
| [`docs/debug_cable_regions.svg`](docs/debug_cable_regions.svg) | Diagram |

Online: https://opentitan.org/book/hw/ip/adc_ctrl/

> These track upstream HEAD, not our pinned commit. For exact behaviour
> always read the local `docs/` and the RTL.

---

## Getting started

```bash
source scripts/activate_env.sh
cd IP/adc_ctrl/sim
./run_compile.sh          # elaborate + run the do-nothing test
```

Then follow the five steps in [`verification/README.md`](verification/README.md).
Your first real deliverable is `verification/testplan.md`, written from
`docs/theory_of_operation.md` — not from this file.
