# pattgen

> ⚠️ **This README is auto-generated** by `IP/scripts/gen_readme.py` and
> contains only facts extracted from the RTL and the upstream docs. It has
> **not** been curated with spec analysis. For examples of what a curated
> IP page looks like, see [`../uart/README.md`](../uart/README.md) or
> [`../rv_plic/README.md`](../rv_plic/README.md). Improving this file as you
> read the spec is a legitimate part of the exercise.

| | |
|---|---|
| **Tier** | starter — Two channels shifting a programmed pattern out |
| **Source** | `vendor/opentitan/hw/ip/pattgen/` @ `365c167e` |
| **Top module** | `pattgen` (`rtl/pattgen.sv`) |
| **RTL files** | 6 (including 0 externally-owned packages) |
| **DUT ports** | 16 |
| **Bus** | TL-UL device |
| **Interrupts** | 2 |
| **Clock domains** | 1 (`clk_i`) |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

---

## Interfaces

| Group | Present |
|---|---|
| Clock/reset | `clk_i` |
| TL-UL bus | `tl_i`, `tl_o` |
| Chip IO (`cio_*`) | 8 port(s): `cio_pda0_tx_o`, `cio_pcl0_tx_o`, `cio_pda1_tx_o`, `cio_pcl1_tx_o`, `cio_pda0_tx_en_o`, `cio_pcl0_tx_en_o`, `cio_pda1_tx_en_o`, `cio_pcl1_tx_en_o` |
| Interrupts | `intr_done_ch0_o`, `intr_done_ch1_o` |
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
| [`docs/pattgen.hjson`](docs/pattgen.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/pattgen_block_diagram.svg`](docs/pattgen_block_diagram.svg) | Diagram |

Online: https://opentitan.org/book/hw/ip/pattgen/

> These track upstream HEAD, not our pinned commit. For exact behaviour
> always read the local `docs/` and the RTL.

---

## Getting started

```bash
source scripts/activate_env.sh
cd IP/pattgen/sim
./run_compile.sh          # elaborate + run the do-nothing test
```

Then follow the five steps in [`verification/README.md`](verification/README.md).
Your first real deliverable is `verification/testplan.md`, written from
`docs/theory_of_operation.md` — not from this file.
