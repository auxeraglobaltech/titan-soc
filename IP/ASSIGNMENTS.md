# IP catalogue and engineer assignments

23 IPs, 7 engineers. All 23 elaborate clean on Xcelium (verified 2026-08-20) —
each folder is ready to start on today.

> Spec links point at **upstream HEAD**, not our pinned commit `365c167e`. Use
> them for concepts; for exact behaviour read the local `IP/<ip>/docs/` and the
> RTL, which are the pinned versions.

---

## 1. The catalogue

Sorted by tier. **Size** = RTL files (including externally-owned packages the
IP drags in). **Deps** = packages/modules owned by *other* IPs.

| IP | Full name | Spec | Tier | RTL | Ports | IRQs | Clks | Deps |
|---|---|---|---|---|---|---|---|---|
| `gpio` | General Purpose Input/Output | [spec](https://opentitan.org/book/hw/top_earlgrey/ip_autogen/gpio/) | starter | 4 | 14 | 1 | 1 | 0 |
| `rv_timer` | RISC-V Timer | [spec](https://opentitan.org/book/hw/ip/rv_timer/) | starter | 4 | 9 | 1 | 1 | 0 |
| `pwm` | Pulse-Width Modulation | [spec](https://opentitan.org/book/hw/top_earlgrey/ip_autogen/pwm/) | starter | 5 | 12 | 0 | **2** | 0 |
| `pattgen` | Pattern Generator | [spec](https://opentitan.org/book/hw/ip/pattgen/) | starter | 6 | 16 | 2 | 1 | 0 |
| `aon_timer` | Always-On Timer (wakeup + watchdog) | [spec](https://opentitan.org/book/hw/ip/aon_timer/) | starter | 8 | 17 | 2 | **2** | 3 |
| `hmac` | Hash-based Message Authentication Code (SHA-2) | [spec](https://opentitan.org/book/hw/ip/hmac/) | starter+ | 4 | 10 | 3 | 1 | 0 |
| `uart` | Universal Asynchronous Receiver/Transmitter | [spec](https://opentitan.org/book/hw/ip/uart/) | intermediate | 6 | 21 | 9 | 1 | 0 |
| `adc_ctrl` | Analog-to-Digital Converter Controller | [spec](https://opentitan.org/book/hw/ip/adc_ctrl/) | intermediate | 8 | 12 | 1 | **2** | 1 |
| `mbx` | Mailbox | [spec](https://opentitan.org/book/hw/ip/mbx/) | intermediate | 10 | 19 | 3 | 1 | 0 |
| `pinmux` | Pin Multiplexer | [spec](https://opentitan.org/book/hw/top_earlgrey/ip_autogen/pinmux/) | intermediate | 17 | **53** | 0 | **2** | 4 |
| `dma` | Direct Memory Access Controller | [spec](https://opentitan.org/book/hw/ip/dma/) | intermediate+ | 4 | 19 | 3 | 1 | 0 |
| `i2c` | Inter-Integrated Circuit (host + target) | [spec](https://opentitan.org/book/hw/ip/i2c/) | intermediate+ | 10 | 32 | **15** | 1 | 0 |
| `spi_host` | Serial Peripheral Interface — Host | [spec](https://opentitan.org/book/hw/ip/spi_host/) | intermediate+ | 14 | 21 | 2 | 1 | 2 |
| `rv_plic` | RISC-V Platform-Level Interrupt Controller | [spec](https://opentitan.org/book/hw/top_earlgrey/ip_autogen/rv_plic/) | advanced | 5 | 10 | 1 | 1 | 0 |
| `usbdev` | USB 2.0 Full-Speed Device | [spec](https://opentitan.org/book/hw/ip/usbdev/) | advanced | 16 | **50** | **18** | 2 | 0 |
| `pwrmgr` | Power Manager | [spec](https://opentitan.org/book/hw/top_earlgrey/ip_autogen/pwrmgr/) | advanced | 17 | 38 | 1 | **4** | 6 |
| `spi_device` | Serial Peripheral Interface — Device | [spec](https://opentitan.org/book/hw/ip/spi_device/) | advanced | 19 | 33 | 8 | 1 | 0 |
| `rv_dm` | RISC-V Debug Module | [spec](https://opentitan.org/book/hw/ip/rv_dm/) | advanced | 26 | 35 | 0 | 2 | 3 |
| `flash_ctrl` | Flash Controller | [spec](https://opentitan.org/book/hw/top_earlgrey/ip_autogen/flash_ctrl/) | advanced | 41 | 48 | 6 | 2 | **14** |
| `kmac` | Keccak Message Authentication Code (SHA-3) | [spec](https://opentitan.org/book/hw/ip/kmac/) | security | 26 | 20 | 3 | 2 | 9 |
| `csrng` | Cryptographically Secure Random Number Generator | [spec](https://opentitan.org/book/hw/ip/csrng/) | security | 37 | 16 | 4 | 1 | 6 |
| `otbn` | OpenTitan Big Number Accelerator | [spec](https://opentitan.org/book/hw/ip/otbn/) | security | 45 | 26 | 1 | 3 | 10 |
| `aes` | Advanced Encryption Standard accelerator | [spec](https://opentitan.org/book/hw/ip/aes/) | security | 50 | 14 | 0 | 2 | 9 |

Also relevant: **TileLink-UL**, the bus every one of these speaks
([spec](https://opentitan.org/book/hw/ip/tlul/)). Not an assignable IP — it is
the shared substrate in `IP/common/rtl/tlul/`. Everyone needs to read it.

---

## 2. Assignments

**Team**: 4 intermediate engineers (prior AXI, AES and DMA work) and 3 junior
engineers (one simple IP UVM environment each).

Each engineer gets an ordered queue, not a parallel workload. **Finish one
before starting the next** — the point is depth, and IP #2 goes far faster than
IP #1.

### Junior engineers

Pattern: two ramp IPs to build the environment skeleton twice, then one
intermediate IP as the stretch goal.

| | 1st — ramp | 2nd — consolidate | 3rd — stretch |
|---|---|---|---|
| **J1** | `gpio` | `pattgen` | `uart` |
| **J2** | `pwm` | `rv_timer` | `adc_ctrl` |
| **J3** | `hmac` | `aon_timer` | `mbx` |

Why these:

- **J1 — `gpio` → `pattgen` → `uart`.** `gpio` is the cleanest possible start:
  no protocol, and checking is "did the pin do what the register said".
  `pattgen` reuses that shape with a shift-out timing element. `uart` is the
  first real serial protocol and 9 interrupts — a genuine step up, by which
  point J1 has built the agent/scoreboard pattern twice.
- **J2 — `pwm` → `rv_timer` → `adc_ctrl`.** `pwm` has a small register file and
  no interrupts, but **two clock domains** — CDC awareness from day one, which
  is worth acquiring early. `rv_timer` is the simplest counter/compare IP.
  `adc_ctrl` adds a sampling FSM plus a second clock again.
- **J3 — `hmac` → `aon_timer` → `mbx`.** `hmac` is small (4 RTL files) and its
  reference model is a library call, so the scoreboard is easy to get right —
  a good first taste of model-based checking. `aon_timer` adds an always-on
  domain and its first external dependency (`lc_ctrl` packages). `mbx` is a
  doorbell/inbox/outbox between two bus masters.

### Intermediate engineers

Matched to stated background.

| | Focus | Queue |
|---|---|---|
| **E1** | AES / crypto | `aes` → `kmac` → `i2c` |
| **E2** | Math-heavy, model-based | `csrng` → `otbn` → `rv_plic` |
| **E3** | DMA / memory / storage | `dma` → `spi_host` → `spi_device` → `flash_ctrl` |
| **E4** | System / IO / debug | `pinmux` → `usbdev` → `pwrmgr` → `rv_dm` |

Why these:

- **E1** goes straight at prior AES experience. `aes` is the largest RTL here
  (50 files) with a masked datapath — a reference model and DOM awareness are
  mandatory. `kmac` is the same shape in Keccak. `i2c` afterwards as a change
  of pace: open-drain bus, host *and* target mode, 15 interrupts.
- **E2** takes the two IPs where directed testing genuinely does not work.
  `csrng` is a NIST SP 800-90A CTR_DRBG — you must model the DRBG. `otbn` is a
  whole processor, verified at ISA level. `rv_plic` closes it out: 186 sources,
  where the correct answer is a priority computation you have to reproduce.
- **E3** starts at `dma` — small in RTL (4 files) but the only IP here that
  **initiates** bus traffic, so it needs a TL-UL *device* agent as well as a
  host one. That is the direct analogue of prior AXI master work. Then the two
  SPI IPs, then `flash_ctrl` (scrambling, ECC, program/erase, 14 external
  dependencies).
- **E4** takes the system corner. `pinmux` first (53 ports, but conceptually a
  muxing matrix — a gentle start at this tier), then `usbdev` (50 ports, 18
  interrupts, needs a USB link-layer model), `pwrmgr` (**4 clock domains**), and
  `rv_dm` last (JTAG, needs a DTM/DMI model).

### Load check

Weighting starter=1, starter+=1.5, intermediate=2, intermediate+=3,
advanced=4, security=5:

| Engineer | IPs | Weight |
|---|---|---|
| J1 | 3 | 4.0 |
| J2 | 3 | 4.0 |
| J3 | 3 | 4.5 |
| E1 | 3 | 13 |
| E2 | 3 | 14 |
| E3 | 4 | 14 |
| E4 | 4 | 14 |

Deliberately uneven between the two groups. A junior's first IP is mostly
*learning the methodology*, and will take far longer than its weight suggests;
by their third they should be at roughly half a senior's rate.

---

## 3. Notes for whoever runs this

- **`csrng` and `aes` overlap.** `csrng` pulls in the entire AES cipher core —
  CTR_DRBG uses AES as its block cipher. E1 and E2 should compare notes; E1
  doing `aes` first means E2 has someone to ask.
- **`spi_host` and `spi_device` are related but not duplicates.** Giving both to
  E3 is deliberate — the second is much cheaper once the first agent exists.
  `spi_host` also depends on `spi_device`'s packages.
- **`rv_plic` is scheduled last for E2 on purpose.** It looks trivial (5 RTL
  files, 10 ports) and is not: the difficulty is entirely in modelling
  priority, tie-break and the claim/complete handshake across 186 sources.
- **Six IPs have curated READMEs** (`gpio`, `pwm`, `uart`, `i2c`, `spi_host`,
  `rv_plic`) with hand-written spec analysis. The other 17 are auto-generated
  facts only, and say so at the top. Improving one is a legitimate first task
  and a good way to prove the spec has actually been read.
- **First deliverable is always `verification/testplan.md`**, written from the
  spec *before* any SystemVerilog. Upstream's own testplan
  (`data/<ip>_testplan.hjson` in the vendor tree) is deliberately not copied in —
  it is the answer key. Diff against it after.

### Assumptions worth correcting

This split was derived from IP complexity metrics plus the stated experience of
each group. It does **not** account for individual names, availability, project
deadlines, or who wants to learn what. Treat the queues as a starting proposal;
the ordering within each queue matters more than the exact allocation.
