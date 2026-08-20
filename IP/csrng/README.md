# csrng

> ⚠️ **This README is auto-generated** by `IP/scripts/gen_readme.py` and
> contains only facts extracted from the RTL and the upstream docs. It has
> **not** been curated with spec analysis. For examples of what a curated
> IP page looks like, see [`../uart/README.md`](../uart/README.md) or
> [`../rv_plic/README.md`](../rv_plic/README.md). Improving this file as you
> read the spec is a legitimate part of the exercise.

| | |
|---|---|
| **Tier** | advanced/security — NIST SP 800-90A DRBG; reference model essentially mandatory |
| **Source** | `vendor/opentitan/hw/ip/csrng/` @ `365c167e` |
| **Top module** | `csrng` (`rtl/csrng.sv`) |
| **RTL files** | 16 (including 6 externally-owned packages) |
| **DUT ports** | 16 |
| **Bus** | TL-UL device |
| **Interrupts** | 4 |
| **Clock domains** | 1 (`clk_i`) |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

---

## External dependencies

This IP references packages owned by *other* IPs, so they are copied into
`rtl/` and listed first in `rtl/files.f`:

| Package | From |
|---|---|
| `lc_ctrl_state_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv` |
| `lc_ctrl_reg_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv` |
| `aes_reg_pkg.sv` | `hw/ip/aes/rtl/aes_reg_pkg.sv` |
| `lc_ctrl_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv` |
| `entropy_src_pkg.sv` | `hw/ip/entropy_src/rtl/entropy_src_pkg.sv` |
| `aes_pkg.sv` | `hw/ip/aes/rtl/aes_pkg.sv` |

They are deliberately **not** in `IP/common/` — that carries what *every*
IP needs, not what *any* IP might need. See
[`../common/README.md`](../common/README.md). Resolved automatically by
`scripts/resolve_deps.py`.

---

## Interfaces

| Group | Present |
|---|---|
| Clock/reset | `clk_i` |
| TL-UL bus | `tl_i`, `tl_o` |
| Chip IO (`cio_*`) | 0 port(s) — none |
| Interrupts | `intr_cs_cmd_req_done_o`, `intr_cs_entropy_req_o`, `intr_cs_hw_inst_exc_o`, `intr_cs_fatal_err_o` |
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
| [`docs/csrng.hjson`](docs/csrng.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/csrng_blk_diag.svg`](docs/csrng_blk_diag.svg) | Diagram |

Online: https://opentitan.org/book/hw/ip/csrng/

> These track upstream HEAD, not our pinned commit. For exact behaviour
> always read the local `docs/` and the RTL.

---

## Getting started

```bash
source scripts/activate_env.sh
cd IP/csrng/sim
./run_compile.sh          # elaborate + run the do-nothing test
```

Then follow the five steps in [`verification/README.md`](verification/README.md).
Your first real deliverable is `verification/testplan.md`, written from
`docs/theory_of_operation.md` — not from this file.
