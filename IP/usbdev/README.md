# usbdev

> ⚠️ **This README is auto-generated** by `IP/scripts/gen_readme.py` and
> contains only facts extracted from the RTL and the upstream docs. It has
> **not** been curated with spec analysis. For examples of what a curated
> IP page looks like, see [`../uart/README.md`](../uart/README.md) or
> [`../rv_plic/README.md`](../rv_plic/README.md). Improving this file as you
> read the spec is a legitimate part of the exercise.

| | |
|---|---|
| **Tier** | advanced — Full USB 2.0 FS device; needs a link-layer model |
| **Source** | `vendor/opentitan/hw/ip/usbdev/` @ `365c167e` |
| **Top module** | `usbdev` (`rtl/usbdev.sv`) |
| **RTL files** | 16 (including 0 externally-owned packages) |
| **DUT ports** | 50 |
| **Bus** | TL-UL device |
| **Interrupts** | 18 |
| **Clock domains** | 2 (`clk_i`, `clk_aon_i`) |
| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |
| **Environment built** | 🔲 not started |

---

## Interfaces

| Group | Present |
|---|---|
| Clock/reset | `clk_i`, `clk_aon_i` |
| TL-UL bus | `tl_i`, `tl_o` |
| Chip IO (`cio_*`) | 7 port(s): `cio_usb_dp_i`, `cio_usb_dn_i`, `cio_usb_dp_o`, `cio_usb_dp_en_o`, `cio_usb_dn_o`, `cio_usb_dn_en_o`, `cio_sense_i` |
| Interrupts | `intr_pkt_received_o`, `intr_pkt_sent_o`, `intr_powered_o`, `intr_disconnected_o`, `intr_host_lost_o`, `intr_link_reset_o`, `intr_link_suspend_o`, `intr_link_resume_o`, `intr_av_out_empty_o`, `intr_rx_full_o`, `intr_av_overflow_o`, `intr_link_in_err_o`, `intr_link_out_err_o`, `intr_rx_crc_err_o`, `intr_rx_pid_err_o`, `intr_rx_bitstuff_err_o`, `intr_frame_o`, `intr_av_setup_empty_o` |
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
| [`docs/usbdev.hjson`](docs/usbdev.hjson) | Machine-readable register description — **generate your RAL from this** |
| [`docs/dualpmod-sch.svg`](docs/dualpmod-sch.svg) | Diagram |
| [`docs/usbdev_block.svg`](docs/usbdev_block.svg) | Diagram |

Online: https://opentitan.org/book/hw/ip/usbdev/

> These track upstream HEAD, not our pinned commit. For exact behaviour
> always read the local `docs/` and the RTL.

---

## Getting started

```bash
source scripts/activate_env.sh
cd IP/usbdev/sim
./run_compile.sh          # elaborate + run the do-nothing test
```

Then follow the five steps in [`verification/README.md`](verification/README.md).
Your first real deliverable is `verification/testplan.md`, written from
`docs/theory_of_operation.md` — not from this file.
