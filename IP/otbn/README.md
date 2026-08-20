# otbn

> ⚠️ **This README is auto-generated** by `IP/scripts/gen_readme.py` and
> contains only facts extracted from the RTL and the upstream docs. It has
> **not** been curated with spec analysis. For examples of what a curated
> IP page looks like, see [`../uart/README.md`](../uart/README.md) or
> [`../rv_plic/README.md`](../rv_plic/README.md). Improving this file as you
> read the spec is a legitimate part of the exercise.

| | |
|---|---|
| **Tier** | advanced/security — A whole processor -- ISA-level verification |
| **Source** | `vendor/opentitan/hw/ip/otbn/` @ `365c167e` |
| **Top module** | `otbn` (`rtl/otbn.sv`) |
| **RTL files** | 43 (including 10 externally-owned packages) |
| **DUT ports** | 26 |
| **Bus** | TL-UL device |
| **Interrupts** | 1 |
| **Clock domains** | 3 (`clk_i`, `clk_edn_i`, `clk_otp_i`) |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

---

## External dependencies

This IP references packages owned by *other* IPs, so they are copied into
`rtl/` and listed first in `rtl/files.f`:

| Package | From |
|---|---|
| `csrng_reg_pkg.sv` | `hw/ip/csrng/rtl/csrng_reg_pkg.sv` |
| `lc_ctrl_state_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv` |
| `lc_ctrl_reg_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv` |
| `keymgr_reg_pkg.sv` | `hw/ip/keymgr/rtl/keymgr_reg_pkg.sv` |
| `entropy_src_pkg.sv` | `hw/ip/entropy_src/rtl/entropy_src_pkg.sv` |
| `csrng_pkg.sv` | `hw/ip/csrng/rtl/csrng_pkg.sv` |
| `otp_ctrl_pkg.sv` | `hw/ip/otp_ctrl/rtl/otp_ctrl_pkg.sv` |
| `lc_ctrl_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv` |
| `keymgr_pkg.sv` | `hw/ip/keymgr/rtl/keymgr_pkg.sv` |
| `edn_pkg.sv` | `hw/ip/edn/rtl/edn_pkg.sv` |

They are deliberately **not** in `IP/common/` — that carries what *every*
IP needs, not what *any* IP might need. See
[`../common/README.md`](../common/README.md). Resolved automatically by
`scripts/resolve_deps.py`.

---

## Interfaces

| Group | Present |
|---|---|
| Clock/reset | `clk_i`, `clk_edn_i`, `clk_otp_i` |
| TL-UL bus | `tl_i`, `tl_o` |
| Chip IO (`cio_*`) | 0 port(s) — none |
| Interrupts | `intr_done_o` |
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
| [`docs/checklist.md`](docs/checklist.md) | Upstream's sign-off checklist |
| [`docs/otbn.hjson`](docs/otbn.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/bn_trn_illustration.svg`](docs/bn_trn_illustration.svg) | Diagram |
| [`docs/otbn_blockarch.svg`](docs/otbn_blockarch.svg) | Diagram |
| [`docs/otbn_development_process.svg`](docs/otbn_development_process.svg) | Diagram |
| [`docs/otbn_operation.svg`](docs/otbn_operation.svg) | Diagram |
| [`docs/otbn_operational_states.svg`](docs/otbn_operational_states.svg) | Diagram |
| [`docs/pack_instruction_shifting.svg`](docs/pack_instruction_shifting.svg) | Diagram |
| [`docs/packed_format.svg`](docs/packed_format.svg) | Diagram |
| [`docs/rshi.svg`](docs/rshi.svg) | Diagram |

Online: https://opentitan.org/book/hw/ip/otbn/

> These track upstream HEAD, not our pinned commit. For exact behaviour
> always read the local `docs/` and the RTL.

---

## Getting started

```bash
source scripts/activate_env.sh
cd IP/otbn/sim
./run_compile.sh          # elaborate + run the do-nothing test
```

Then follow the five steps in [`verification/README.md`](verification/README.md).
Your first real deliverable is `verification/testplan.md`, written from
`docs/theory_of_operation.md` — not from this file.
