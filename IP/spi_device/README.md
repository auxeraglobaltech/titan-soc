# spi_device

> ⚠️ **This README is auto-generated** by `IP/scripts/gen_readme.py` and
> contains only facts extracted from the RTL and the upstream docs. It has
> **not** been curated with spec analysis. For examples of what a curated
> IP page looks like, see [`../uart/README.md`](../uart/README.md) or
> [`../rv_plic/README.md`](../rv_plic/README.md). Improving this file as you
> read the spec is a legitimate part of the exercise.

| | |
|---|---|
| **Tier** | advanced — Flash/passthrough/generic modes -- effectively three IPs |
| **Source** | `vendor/opentitan/hw/ip/spi_device/` @ `365c167e` |
| **Top module** | `spi_device` (`rtl/spi_device.sv`) |
| **RTL files** | 19 (including 0 externally-owned packages) |
| **DUT ports** | 33 |
| **Bus** | TL-UL device |
| **Interrupts** | 8 |
| **Clock domains** | 1 (`clk_i`) |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

---

## Interfaces

| Group | Present |
|---|---|
| Clock/reset | `clk_i` |
| TL-UL bus | `tl_i`, `tl_o` |
| Chip IO (`cio_*`) | 6 port(s): `cio_sck_i`, `cio_csb_i`, `cio_sd_o`, `cio_sd_en_o`, `cio_sd_i`, `cio_tpm_csb_i` |
| Interrupts | `intr_upload_cmdfifo_not_empty_o`, `intr_upload_payload_not_empty_o`, `intr_upload_payload_overflow_o`, `intr_readbuf_watermark_o`, `intr_readbuf_flip_o`, `intr_tpm_header_not_empty_o`, `intr_tpm_rdfifo_cmd_end_o`, `intr_tpm_rdfifo_drop_o` |
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
| [`docs/spi_device.hjson`](docs/spi_device.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/block_diagram.svg`](docs/block_diagram.svg) | Diagram |
| [`docs/buffer-management.svg`](docs/buffer-management.svg) | Diagram |
| [`docs/cmdparse.svg`](docs/cmdparse.svg) | Diagram |
| [`docs/passthrough-filter.svg`](docs/passthrough-filter.svg) | Diagram |
| [`docs/read_pipeline.svg`](docs/read_pipeline.svg) | Diagram |
| [`docs/spid_sram_layout.svg`](docs/spid_sram_layout.svg) | Diagram |
| [`docs/tpm-blockdiagram.svg`](docs/tpm-blockdiagram.svg) | Diagram |

Online: https://opentitan.org/book/hw/ip/spi_device/

> These track upstream HEAD, not our pinned commit. For exact behaviour
> always read the local `docs/` and the RTL.

---

## Getting started

```bash
source scripts/activate_env.sh
cd IP/spi_device/sim
./run_compile.sh          # elaborate + run the do-nothing test
```

Then follow the five steps in [`verification/README.md`](verification/README.md).
Your first real deliverable is `verification/testplan.md`, written from
`docs/theory_of_operation.md` — not from this file.
