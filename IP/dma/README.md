# dma

> ⚠️ **This README is auto-generated** by `IP/scripts/gen_readme.py` and
> contains only facts extracted from the RTL and the upstream docs. It has
> **not** been curated with spec analysis. For examples of what a curated
> IP page looks like, see [`../uart/README.md`](../uart/README.md) or
> [`../rv_plic/README.md`](../rv_plic/README.md). Improving this file as you
> read the spec is a legitimate part of the exercise.

| | |
|---|---|
| **Tier** | intermediate — Address generation and bus mastering; it initiates traffic |
| **Source** | `vendor/opentitan/hw/ip/dma/` @ `365c167e` |
| **Top module** | `dma` (`rtl/dma.sv`) |
| **RTL files** | 4 (including 0 externally-owned packages) |
| **DUT ports** | 19 |
| **Bus** | no TL-UL port |
| **Interrupts** | 3 |
| **Clock domains** | 1 (`clk_i`) |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

---

## Interfaces

| Group | Present |
|---|---|
| Clock/reset | `clk_i` |
| TL-UL bus | — |
| Chip IO (`cio_*`) | 0 port(s) — none |
| Interrupts | `intr_dma_done_o`, `intr_dma_chunk_done_o`, `intr_dma_error_o` |
| Alerts | yes |
| RACL | yes |

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
| [`docs/dma.hjson`](docs/dma.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/block_diagram.svg`](docs/block_diagram.svg) | Diagram |
| [`docs/secure_perimeter.svg`](docs/secure_perimeter.svg) | Diagram |
| [`docs/sub_words.svg`](docs/sub_words.svg) | Diagram |

Online: https://opentitan.org/book/hw/ip/dma/

> These track upstream HEAD, not our pinned commit. For exact behaviour
> always read the local `docs/` and the RTL.

---

## Getting started

```bash
source scripts/activate_env.sh
cd IP/dma/sim
./run_compile.sh          # elaborate + run the do-nothing test
```

Then follow the five steps in [`verification/README.md`](verification/README.md).
Your first real deliverable is `verification/testplan.md`, written from
`docs/theory_of_operation.md` — not from this file.
