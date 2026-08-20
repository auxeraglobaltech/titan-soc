# flash_ctrl

> ⚠️ **This README is auto-generated** by `IP/scripts/gen_readme.py` and
> contains only facts extracted from the RTL and the upstream docs. It has
> **not** been curated with spec analysis. For examples of what a curated
> IP page looks like, see [`../uart/README.md`](../uart/README.md) or
> [`../rv_plic/README.md`](../rv_plic/README.md). Improving this file as you
> read the spec is a legitimate part of the exercise.

| | |
|---|---|
| **Tier** | advanced — Scrambling, ECC, program/erase, lifecycle interaction |
| **Source** | `vendor/opentitan/hw/top_earlgrey/ip_autogen/flash_ctrl/` @ `365c167e` |
| **Top module** | `flash_ctrl` (`rtl/flash_ctrl.sv`) |
| **RTL files** | 37 (including 14 externally-owned packages) |
| **DUT ports** | 48 |
| **Bus** | no TL-UL port |
| **Interrupts** | 6 |
| **Clock domains** | 2 (`clk_i`, `clk_otp_i`) |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

> ⚠️ **Generated IP.** The upstream source of truth is the template at
> `hw/ip_templates/flash_ctrl/`, instantiated for Earl Grey. What is copied here
> is the *generated Earl Grey instance*, which is what you want — it matches
> the chip the SoC track verifies. Do not look for it under `hw/ip/`.

---

## External dependencies

This IP references packages owned by *other* IPs, so they are copied into
`rtl/` and listed first in `rtl/files.f`:

| Package | From |
|---|---|
| `csrng_reg_pkg.sv` | `hw/ip/csrng/rtl/csrng_reg_pkg.sv` |
| `rom_ctrl_pkg.sv` | `hw/ip/rom_ctrl/rtl/rom_ctrl_pkg.sv` |
| `pwrmgr_reg_pkg.sv` | `hw/top_darjeeling/ip_autogen/pwrmgr/rtl/pwrmgr_reg_pkg.sv` |
| `lc_ctrl_state_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_state_pkg.sv` |
| `lc_ctrl_reg_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_reg_pkg.sv` |
| `entropy_src_pkg.sv` | `hw/ip/entropy_src/rtl/entropy_src_pkg.sv` |
| `csrng_pkg.sv` | `hw/ip/csrng/rtl/csrng_pkg.sv` |
| `pwrmgr_pkg.sv` | `hw/top_darjeeling/ip_autogen/pwrmgr/rtl/pwrmgr_pkg.sv` |
| `otp_ctrl_pkg.sv` | `hw/ip/otp_ctrl/rtl/otp_ctrl_pkg.sv` |
| `lc_ctrl_pkg.sv` | `hw/ip/lc_ctrl/rtl/lc_ctrl_pkg.sv` |
| `jtag_pkg.sv` | `hw/ip/rv_dm/rtl/jtag_pkg.sv` |
| `flash_ctrl_pkg.sv` | `hw/ip/flash_ctrl/rtl/flash_ctrl_pkg.sv` |
| `edn_pkg.sv` | `hw/ip/edn/rtl/edn_pkg.sv` |
| `ast_pkg.sv` | `hw/top_darjeeling/ip/ast/rtl/ast_pkg.sv` |

They are deliberately **not** in `IP/common/` — that carries what *every*
IP needs, not what *any* IP might need. See
[`../common/README.md`](../common/README.md). Resolved automatically by
`scripts/resolve_deps.py`.

---

## Interfaces

| Group | Present |
|---|---|
| Clock/reset | `clk_i`, `clk_otp_i` |
| TL-UL bus | — |
| Chip IO (`cio_*`) | 5 port(s): `cio_tck_i`, `cio_tms_i`, `cio_tdi_i`, `cio_tdo_en_o`, `cio_tdo_o` |
| Interrupts | `intr_corr_err_o`, `intr_prog_empty_o`, `intr_prog_lvl_o`, `intr_rd_full_o`, `intr_rd_lvl_o`, `intr_op_done_o` |
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
| [`docs/flash_ctrl.hjson`](docs/flash_ctrl.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/flash_abstraction.svg`](docs/flash_abstraction.svg) | Diagram |
| [`docs/flash_block_diagram.svg`](docs/flash_block_diagram.svg) | Diagram |
| [`docs/flash_boundaries.svg`](docs/flash_boundaries.svg) | Diagram |
| [`docs/flash_integrity.svg`](docs/flash_integrity.svg) | Diagram |
| [`docs/flash_partitions.svg`](docs/flash_partitions.svg) | Diagram |
| [`docs/flash_protocol_controller.svg`](docs/flash_protocol_controller.svg) | Diagram |
| [`docs/flash_read_pipeline.svg`](docs/flash_read_pipeline.svg) | Diagram |

Online: https://opentitan.org/book/hw/top_earlgrey/ip_autogen/flash_ctrl/

> These track upstream HEAD, not our pinned commit. For exact behaviour
> always read the local `docs/` and the RTL.

---

## Getting started

```bash
source scripts/activate_env.sh
cd IP/flash_ctrl/sim
./run_compile.sh          # elaborate + run the do-nothing test
```

Then follow the five steps in [`verification/README.md`](verification/README.md).
Your first real deliverable is `verification/testplan.md`, written from
`docs/theory_of_operation.md` — not from this file.
