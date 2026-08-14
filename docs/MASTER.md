# titan-soc — Master Reference

**The single source of truth for this project.** Start here; everything else is
either a detail page linked from below, or upstream OpenTitan documentation.

| | |
|---|---|
| **Project** | titan-soc — SoC-level DV training environment |
| **DUT** | OpenTitan **Earl Grey** (silicon Root of Trust) |
| **Simulator** | Cadence Xcelium (`xrun`) 25.03-s001 |
| **Methodology** | UVM 1.2 (`-uvmhome CDNS-1.2`), OpenTitan DV environment reused wholesale |
| **Pinned OT commit** | [`365c167e`](https://github.com/lowrisc/opentitan/tree/365c167ef632534a1282c780d8b990f46dfbccbf) (2026-06-04) |
| **Repo** | `git@github.com:auxeraglobaltech/titan-soc.git`, branch `main` |
| **Status** | 9/9 smoke tests passing — see [§3](#3-current-status) |
| **Last updated** | 2026-08-14 |

---

## Table of contents

1. [What this project is](#1-what-this-project-is)
2. [What Earl Grey is (the security SoC)](#2-what-earl-grey-is-the-security-soc)
3. [Current status](#3-current-status)
4. [Commands — everything you can run](#4-commands--everything-you-can-run)
5. [SoC architecture](#5-soc-architecture)
6. [Memory map](#6-memory-map)
7. [The DV environment](#7-the-dv-environment)
8. [How a test actually works](#8-how-a-test-actually-works)
9. [Adding your own test](#9-adding-your-own-test)
10. [Repo map](#10-repo-map)
11. [Known quirks index](#11-known-quirks-index)
12. [Specifications & external links](#12-specifications--external-links)
13. [Glossary](#13-glossary)

---

## 1. What this project is

titan-soc is a **training environment for SoC-level design verification**. The
goal is for an engineer who knows block-level DV to learn chip-level DV on a
real, non-trivial design rather than a toy.

The design under test is not written here. It is OpenTitan Earl Grey, pinned as
a git submodule at `vendor/opentitan/`. Neither is the UVM infrastructure —
OpenTitan ships a complete chip-level DV environment (agents, scoreboards,
sequences, RAL) and we reuse it verbatim.

**What we add** is test content, layered on top without forking upstream:

- **C test programs** (`sw/trainee/`) that run on the chip's RISC-V core and
  drive real hardware through registers.
- **UVM virtual sequences** (`tests/smoke/`) that drive or observe the chip's
  pins from the testbench side.
- **Configuration** (`overlay/`) that registers those tests with the build
  system without editing vendor files.

This is called **Option B** in `ARCHITECTURE.md`: *reuse the DV infra, write
only test content*. The alternative (build an environment from scratch) teaches
UVM plumbing but not chip-level verification, and would take months before the
first meaningful test.

### Why a real SoC and not a toy

A toy design cannot teach the things that actually make chip-level DV hard, all
of which this project has already hit in practice:

- The DUT boots real firmware from a ROM before your test runs.
- Software and testbench must **synchronise** without shared memory — they can
  only see each other through pins and a status word.
- X-propagation from an undriven pad kills a run 300µs after the actual mistake.
- Build systems (FuseSoC + Bazel + dvsim) fail in ways unrelated to your RTL.

---

## 2. What Earl Grey is (the security SoC)

**OpenTitan** is the first open-source **silicon Root of Trust (RoT)**. A root
of trust is the component a system trusts unconditionally — it is the anchor
every other security claim depends on. In practice, an RoT chip:

- verifies that firmware is authentic before allowing it to run (**secure boot**),
- stores cryptographic keys such that software can use them but never read them,
- provides a hardware identity that cannot be cloned,
- resists an attacker with **physical access** to the board.

**Earl Grey** is OpenTitan's discrete-chip design: a standalone security chip
that sits alongside a main CPU, in the role of a TPM, a server platform RoT, or
a security key.

### What makes it a *security* chip

An ordinary microcontroller with the same peripherals would be a fraction of
the size. The difference is that Earl Grey assumes the attacker owns the board:

| Threat | Countermeasure in the RTL |
|---|---|
| Read out keys/firmware from flash or SRAM | **Scrambling** on flash, SRAM and OTP; keys come from `keymgr`, never software |
| Glitch the clock/voltage to skip a check | **`ast`** analog sensors + **`alert_handler`** escalation to reset |
| Flip a bit with a laser / fault injection | **ECC and integrity** on memories and on the TL-UL bus; duplicated **lockstep** Ibex core |
| Tamper with a peripheral to reach the bus | Every device wrapped in **integrity checking**; violations raise alerts |
| Observe power to extract an AES key | **Masking** in the AES and KMAC datapaths |
| Predict "random" values | **`entropy_src` → `csrng` → `edn`** hardware entropy chain feeding all crypto |
| Downgrade the chip to a debug state | **`lc_ctrl`** life cycle, enforced in hardware, one-way transitions |

Two ideas are worth understanding because they shape the whole DV effort:

**Life cycle (`lc_ctrl`).** The chip moves through states — `RAW` → `TEST_UNLOCKED`
→ `DEV`/`PROD` → `RMA` → `SCRAP`. Debug access (JTAG) is available early and
permanently disabled in `PROD`. Transitions are enforced in hardware and gated
by tokens in OTP. Much of the DV effort exists to prove no path re-enables debug
on a production part.

**Alerts and escalation.** Security IPs do not merely set an interrupt on a
fault — they raise an **alert**. `alert_handler` accumulates alerts and
escalates through phases, ending in a chip reset or permanent shutdown, all
without software cooperation (an attacker may already control software).

### Where our tests sit

Ours are **functional** tests — GPIO, timers, interrupts. They prove the chip
*works*, which is the prerequisite for the security testing above. The security
scenarios (escalation, life cycle, glitch injection) exist in the upstream test
suite and are the natural place to go after the fundamentals; see
`testplan/system.md`.

---

## 3. Current status

**All 9 smoke tests pass 1/1 on Xcelium** (verified 2026-08-14).

| Test | Kind | Plan | Runtime | What it proves |
|---|---|---|---|---|
| `chip_sw_gpio_smoketest` | upstream | CONN-2 | ~164s | GPIO pads reach the TB |
| `chip_sw_uart_smoketest` | upstream | CONN-3 | — | UART TX/RX to the DV agent |
| `chip_sw_rv_timer_smoketest` | upstream | INT-1 | — | timer IRQ reaches Ibex |
| `chip_sw_aon_timer_smoketest` | upstream | INT-2 | — | AON wakeup + watchdog |
| `chip_sw_sram_ctrl_smoketest` | upstream | CONN-4 | — | main + retention SRAM |
| `titan_sw_hello_test` | trainee, C + vseq | CONN-5 | 125s | the trainee workflow end to end |
| `titan_sw_gpio_irq_test` | trainee, C + vseq | INT-3 | 171s | GPIO edge → PLIC → ISR; 8 edges, 8 IRQs |
| `titan_sw_gpio_out_selfcheck_test` | trainee, C only | CONN-2a | 168s | GPIO output loopback, self-checked |
| `titan_sw_rv_timer_irq_test` | trainee, C only | INT-1a | 168s | 5 timer deadlines, one IRQ each |

Build is ~45s incremental, ~90s cold. A full run is ~4 minutes.

### Phase progress

| Phase | Goal | Status |
|---|---|---|
| 0 | Repo skeleton, architecture decisions | ✅ |
| 1 | OT submodule pinned; Xcelium elaboration verified | ✅ |
| 2 | Toolchain, Python env, build prerequisites | ✅ |
| 3 | First chip tests passing (gpio + uart smoke) | ✅ |
| 4 | Testplans, regression suite, trainee workflow | ✅ |
| 5 | Trainee vseq path; cohort exercises; coverage closure | 🔄 in progress |

### Known gaps — be honest about these

- **`sim/regress.sh` has never been run as a full suite.** Every test passes
  individually; the 9-test run is unproven, and its pass/fail logic was
  recently changed.
- **Zero pure-UVM tests.** Every test drives the chip via C on the Ibex core.
  Stub-CPU tests (`chip_stub_cpu_base_vseq`) are a different technique and are
  not yet scoped.
- **No coverage closure yet.** `COV=1` works but no merged report or analysis.
- **INT-4 (UART watermark IRQ)** is specified in `testplan/integration.md` but
  not written.
- **`git status` always shows ` m vendor/opentitan`.** Expected — see
  [§7.4](#74-the-one-vendor-patch).

---

## 4. Commands — everything you can run

### First-time setup

```csh
git clone --recurse-submodules git@github.com:auxeraglobaltech/titan-soc.git
cd titan-soc
./scripts/setup_host_shims.sh          # one-time, no sudo needed
```

If you forgot `--recurse-submodules`:
```csh
git submodule update --init --recursive
```

### Every session

```csh
source scripts/activate_env.csh        # csh/tcsh
source scripts/activate_env.sh         # bash
```

This puts the project venv, Cadence tools and Bazel config on PATH. Verify:
```csh
which dvsim xrun
```

### Running tests

```csh
./sim/run_xcelium.sh                                    # default: chip_sw_gpio_smoketest
env TEST=titan_sw_gpio_irq_test ./sim/run_xcelium.sh    # any registered test
./sim/run_xcelium.sh --build-only                       # elaborate, do not simulate
./sim/run_xcelium.sh --waves shm                        # dump SHM waves
env COV=1 ./sim/run_xcelium.sh                          # with coverage
./sim/regress.sh                                        # all 9 smoke tests, serial
./sim/regress.sh titan_sw_hello_test titan_sw_gpio_irq_test   # explicit list
```

`run_xcelium.sh` re-applies the vendor patch and syncs `sw/trainee/` on every
invocation, both idempotent. **No manual sync step is needed.**

> ⚠️ Only run **one** simulation at a time — the server is shared. Check with `who`.

### Reading results

```csh
less sim/runs/latest/run.log                    # newest run, any test
less sim/runs/<test_name>/run.log               # a specific test
simvision sim/runs/latest/waves.shm &           # waves, if dumped
```

Verification greps (**csh**: use `set X = ...`; csh has no interactive `#`
comments, and an apostrophe opens a quote):

```csh
set L = sim/runs/titan_sw_gpio_irq_test/run.log
stat -c "%y" $L                                 # ALWAYS check freshness first
grep -E "TEST (PASSED|FAILED)" $L
grep -E "^UVM_(ERROR|FATAL) :" $L
grep -c "UVM_TEST_SEQ=titan_gpio_irq_vseq" $L   # confirm the right vseq ran
```

> **Never `grep -i error`** on an Xcelium log — assertion coverage bins are
> named `*errorChangedNotAccepted_C` and swamp real hits. And **always `stat`
> the log**: `sim/runs/<test>/` is overwritten in place, so a build failure
> leaves the previous run's log looking valid (quirk #13).

### When a run fails

| Symptom | Look at |
|---|---|
| Build/elaboration failed | `sim/scratch/HEAD/chip_earlgrey_asic-sim-xcelium/default/build.log` — **not** `run.log` |
| Simulation failed | `sim/runs/<test>/run.log`, and the "Failure Buckets" section dvsim prints |
| SW `LOG_INFO` output | `sim/runs/<test>/tb.u_sim_sram.u_sim_sram_if.u_sw_logger_if.log` |
| SW build failed | `sim/runs/<test>/sw_build.log` |

### Maintenance

```csh
./scripts/apply_vendor_patches.sh      # idempotent; run_xcelium.sh calls it
./scripts/sync_trainee_sw.sh           # idempotent; run_xcelium.sh calls it
git -C vendor/opentitan status --short # expect: M chip_vseq_list.sv
```

Nuclear option after a tool-mount change (quirk #10) — costs one full rebuild:
```csh
rm -rf sim/scratch/HEAD/chip_earlgrey_asic-sim-xcelium/default
```

---

## 5. SoC architecture

📊 **Block diagram**: [`docs/earlgrey_block_diagram.svg`](earlgrey_block_diagram.svg)
— annotated, bus topology taken from the pinned commit's `xbar_{main,peri}.hjson`,
with smoke-verified IPs marked ✓.

### Core

| | |
|---|---|
| CPU | **Ibex** — 32-bit RISC-V. From `top_earlgrey.sv`: `RV32E=0` (32 regs), `RV32M=RV32MSingleCycle`, `RV32B=RV32BOTEarlGrey` (OT-specific bitmanip subset), `RV32ZC` enabled |
| Security | Lockstep duplicate core, dummy instructions, PC hardening |
| Interrupts | `rv_plic` for peripherals; timer + software IRQs direct to the core |
| Debug | `rv_dm` over JTAG, gated by life cycle state |

### Bus topology

TileLink Uncached Lightweight (**TL-UL**), two crossbars:

- **`xbar_main`** — high-bandwidth: SRAM, flash, crypto (`aes`, `hmac`, `kmac`,
  `otbn`, `keymgr`), `spi_host0/1`, `usbdev`, `rv_dm`, `rv_plic`.
- **`xbar_peri`** — slower peripherals: `uart0-3`, `gpio`, `i2c0-2`,
  `spi_device`, `rv_timer`, `pattgen`, `pwm`, and the AON block.

44 module instances in total. Every TL-UL device port is wrapped in integrity
checking — this is what produced the `dKnown_A` assertion failures in quirk #14.

### IP inventory (base addresses from `top_earlgrey.h`)

**Comms** — `uart0` `0x4000_0000`, `uart1` `0x4001_0000`, `uart2` `0x4002_0000`,
`uart3` `0x4003_0000`, `spi_device` `0x4005_0000`, `i2c0` `0x4008_0000`,
`i2c1` `0x4009_0000`, `i2c2` `0x400A_0000`, `spi_host0` `0x4030_0000`,
`spi_host1` `0x4031_0000`, `usbdev` `0x4032_0000`

**I/O & timers** — `gpio` `0x4004_0000`, `pattgen` `0x400E_0000`,
`rv_timer` `0x4010_0000`, `pwm_aon` `0x4045_0000`, `pinmux_aon` `0x4046_0000`,
`aon_timer_aon` `0x4047_0000`

**Crypto & keys** — `aes` `0x4110_0000`, `hmac` `0x4111_0000`,
`kmac` `0x4112_0000`, `otbn` `0x4113_0000`, `keymgr` `0x4114_0000`,
`csrng` `0x4115_0000`, `entropy_src` `0x4116_0000`, `edn0` `0x4117_0000`,
`edn1` `0x4118_0000`

**Security & lifecycle** — `otp_ctrl` `0x4013_0000`, `lc_ctrl` `0x4014_0000`,
`alert_handler` `0x4015_0000`, `sensor_ctrl_aon` `0x4049_0000`,
`rom_ctrl` `0x411E_0000`, `ast` `0x4048_0000`

**Power/reset/clock (AON)** — `pwrmgr_aon` `0x4040_0000`,
`rstmgr_aon` `0x4041_0000`, `clkmgr_aon` `0x4042_0000`,
`sysrst_ctrl_aon` `0x4043_0000`, `adc_ctrl_aon` `0x4044_0000`

**Memory & core** — `flash_ctrl` `0x4100_0000`,
`sram_ctrl_main` `0x411C_0000`, `sram_ctrl_ret_aon` `0x4050_0000`,
`rv_plic` `0x4800_0000`, `rv_dm` `0x4120_0000`,
`rv_core_ibex_cfg` `0x411F_0000`

The AON (always-on) domain keeps running in deep sleep and is what wakes the
chip back up.

---

## 6. Memory map

From `hw/top_earlgrey/sw/autogen/top_earlgrey_memory.ld`:

| Region | Origin | Length | Role |
|---|---|---|---|
| `rom` | `0x0000_8000` | 32 KiB | TEST ROM (or the real ROM) |
| `ram_main` | `0x1000_0000` | 128 KiB | main SRAM, scrambled |
| `eflash` | `0x2000_0000` | 1 MiB | embedded flash — **your test loads into slot A here** |
| `ram_ret_aon` | `0x4060_0000` | 4 KiB | retention SRAM, survives deep sleep |
| `rom_ext_virtual` | `0x9000_0000` | 512 KiB | virtual window, ROM_EXT |
| `owner_virtual` | `0xA000_0000` | 512 KiB | virtual window, owner firmware |

### The test status word — the chip's `tohost`

Chip DV does **not** use the spike `tohost` convention. The OTTF writes a status
word into an unmapped window of `rv_core_ibex`, which the TB monitors via
`sw_test_status_if`. Derivation (`chip_common_pkg.sv:19-23`):

```
ADDR_SPACE_RV_CORE_IBEX__CFG      = 0x411f0000    (tl_main_pkg.sv)
RV_CORE_IBEX_DV_SIM_WINDOW_OFFSET =       0x80    (rv_core_ibex_reg_pkg.sv)

SW_DV_TEST_STATUS_ADDR = 0x411f0080   <- pass/fail status word
SW_DV_LOG_ADDR         = 0x411f0084   <- SW log channel
```

Values are the `sw_test_status_t` enum. A passing run walks:

```
SwTestStatusInBootRom  ->  SwTestStatusInTest  ->  SwTestStatusPassed
```

The TB ends the simulation on `Passed`/`Failed`. **Returning `true` from
`test_main()` is what produces `Passed`.**

---

## 7. The DV environment

### 7.1 Layout (all under `vendor/opentitan/hw/top_earlgrey/dv/`)

| Path | Contents |
|---|---|
| `chip_sim_cfg.hjson` | master dvsim config — every upstream test entry |
| `env/chip_env_pkg.sv` | the UVM package; imports ~40 packages, includes all env classes |
| `env/chip_env_cfg.sv` | env configuration object (`cfg` in sequences) |
| `env/chip_if.sv` | **the chip interface** — all pin-level access (`gpios_if`, clocks, straps) |
| `env/chip_scoreboard.sv` | checking |
| `env/seq_lib/` | ~110 virtual sequences |
| `env/seq_lib/chip_vseq_list.sv` | the include list — **where our hook lives** |
| `env/seq_lib/chip_sw_base_vseq.sv` | base class for SW-driven tests: boot, backdoor load, status tracking |
| `env/seq_lib/chip_stub_cpu_base_vseq.sv` | base for pure-UVM tests (CPU held in reset) |
| `tb/tb.sv` | top-level testbench |

### 7.2 The class you extend

Every trainee vseq extends **`chip_sw_base_vseq`**, which already handles POR,
backdoor-loading your compiled test into flash, and tracking the status word.
Your `body()` calls `super.body()` and then does its own work.

Useful handles inside a sequence:

| Handle | Use |
|---|---|
| `cfg.sw_test_status_vif.sw_test_status` | current SW status; wait on it with `` `DV_WAIT `` |
| `cfg.chip_vif.gpios_if` | drive/sample GPIO pins (`drive_pin`, `drive_en`, `.pins`) |
| `cfg.chip_vif.cpu_clk_rst_if` | `wait_clks(n)` |
| `cfg.sw_images[SwTypeTestSlotA]` | path to your ELF, for symbol lookup |

Two APIs that matter for SW↔TB communication:

- `dv_utils_pkg::sw_symbol_get_addr_size()` — find a C global's address.
- `sw_symbol_backdoor_overwrite()` — write into it. **Must be called in
  `cpu_init()`**, before the CPU reads the value, not in `body()`.

`chip_sw_gpio_smoke_vseq.sv` is the worked example (it randomises `kGpioVals`).

### 7.3 How our tests get compiled in

`overlay/titan_sim_cfg.hjson` imports the vendor config wholesale and appends
our test entries — no vendor test is touched. Two `build_opts` enable our vseqs:

```hjson
build_opts: [
  "+incdir+{self_dir}/../tests/smoke"
  "+define+TITAN_VSEQ_EXTRAS"
]
```

The define activates a guarded `` `include "titan_vseq_list.sv" `` at the end of
the vendor `chip_vseq_list.sv`, which lists our vseqs.

### 7.4 The one vendor patch

> **Why we edit vendor at all**, having said we never would.

Trainee vseqs extend `chip_sw_base_vseq`, which lives *inside* `chip_env_pkg`.
To subclass it, our code must be compiled inside that same package block. Two
facts make every alternative impossible:

1. **dvsim emits `build_opts` before `-f {sv_flist}`**
   (`hw/dv/tools/dvsim/xcelium.hjson:10-17`). Any `.sv` added via `build_opts`
   compiles *before* `chip_env_pkg` exists. **No `build_opts`-based approach can
   work** — including a separate package that imports `chip_env_pkg`.
2. **SV package re-open does not inherit imports.** Re-opening a package appends
   identifiers but starts with none of the first block's ~40 imports, so even
   `` `uvm_object_utils `` fails.

A guarded include inside the original block solves both at once. It is 16 lines,
inert without `+define+TITAN_VSEQ_EXTRAS`, and stored as
`overlay/patches/0001-titan-vseq-hook.patch`.

**It cannot be committed.** `vendor/opentitan` is a submodule, so this repo can
only ever record a dirty-submodule marker, never the content. That is why
`run_xcelium.sh` re-applies it automatically, and why `git status` permanently
shows ` m vendor/opentitan`. Full detail: quirk #12,
[`overlay/patches/README.md`](../overlay/patches/README.md).

---

## 8. How a test actually works

### The chain

```
dvsim  →  FuseSoC (file list)  →  Bazel (compile C to .vmem)  →  xrun (build)  →  xrun (run)
```

### Boot sequence

1. TB releases POR; `chip_sw_base_vseq` backdoor-loads the TEST ROM into `rom`
   and your test image into flash slot A.
2. TEST ROM runs, sets status `InBootRom` (~2560µs).
3. TEST ROM jumps to flash (~2927µs).
4. OTTF init runs, sets status `InTest` (~2931µs) — **your `test_main()` starts**.
5. `test_main()` returns `true` → `Passed` → TB ends the sim.

Those timestamps are real, from `titan_sw_hello_test`. Note ~2.9ms of simulated
time elapses before your code runs; that is the ROM, and it is unavoidable.

### SW ↔ TB synchronisation

They share no memory. The SW sees registers and pins; the TB sees pins and the
status word. Everything else must be built from those.

`titan_sw_gpio_irq_test` is the reference implementation — a three-step pin-level
handshake:

| Step | SW | TB |
|---|---|---|
| 1 | drives test pins **high** as outputs | waits for `pins[3:0] === 4'hF` |
| 2 | releases them (output disable → `z`) | waits for `pins[3:0] === 4'bzzzz` |
| 3 | spins 50µs, then arms interrupts | drives **all 32** pins low, waits `ARM_DELAY_CLKS` (100µs) |
| 4 | waits for IRQs | walks 4 rising, then 4 falling edges, 1100–2000 clks apart |

Measured on the passing run: TB drove low @3245.5µs, SW armed @3296.4µs, first
edge @3345.5µs — a 49µs cushion.

**Two traps this design exists to avoid**, both learned the hard way:

- **Never read `DATA_IN` while any pad floats.** `dif_gpio_read_all()` reads all
  32 bits, so one floating pin returns `X`, and X on a TL-UL response trips
  `dKnown_A` — killing the run ~300µs after the real mistake. This is why the TB
  drives *all* pins, not just the four under test, and why step 3 is a timed
  spin rather than a polling loop (quirk #14).
- **Arm interrupts only after levels are stable**, or the handover transition
  latches a spurious edge and breaks "exactly once per edge".

---

## 9. Adding your own test

### C-only (no testbench interaction)

Sufficient when everything is observable from software — internal IP, or a
loopback that closes on-chip.

1. Write `sw/trainee/<name>.c` — `OTTF_DEFINE_TEST_CONFIG();` and
   `bool test_main(void)`; return `true` to pass.
2. Add an `opentitan_test()` target in `sw/trainee/BUILD` with the right `deps`.
3. Add an entry to `overlay/titan_sim_cfg.hjson` with **no** `uvm_test_seq` — it
   inherits `chip_sw_base_vseq` (`chip_sim_cfg.hjson:158`):

```hjson
{
  name: titan_sw_<name>
  sw_images: ["//sw/device/tests/titan:<name>:1:new_rules"]
  en_run_modes: ["sw_test_mode_test_rom"]
  run_timeout_mins: 60
}
```

Model on `sw/trainee/rv_timer_irq_test.c`.

### C + UVM pair (the TB must drive or observe something)

Steps 1–3 above, plus:

4. Write `tests/smoke/<name>_vseq.sv` extending `chip_sw_base_vseq`.
5. Add one `` `include `` line to `tests/smoke/titan_vseq_list.sv`.
6. Set `uvm_test_seq: <name>_vseq` on the test entry.

Model on `sw/trainee/gpio_irq_test.c` + `tests/smoke/titan_gpio_irq_vseq.sv`.

Then:
```csh
env TEST=titan_sw_<name> ./sim/run_xcelium.sh
```

### Rules that will save you a cycle

- `en_run_modes: ["sw_test_mode_test_rom"]` is **required** — without it the sim
  dies at t=0 with `otp_ctrl_img_rma.vmem could not be opened`.
- Sanity-check the hjson before running:
  ```csh
  .venv/bin/python3 -c "import hjson; hjson.load(open('overlay/titan_sim_cfg.hjson'))"
  ```
- Constants shared between a C file and its vseq (e.g. `kNumTestPins` /
  `NUM_TEST_PINS`) have **no compile-time link**. Change both, or look the value
  up with `sw_symbol_get_addr_size()`.
- `pins_if.drive(val)` asserts the output enable on **all** pins. Use
  `drive_pin(i, val)` to touch only the pins you own.
- Add the test to `SMOKE_TESTS` in `sim/regress.sh` once it is green.

---

## 10. Repo map

```
titan-soc/
├── README.md                    quick-start + test table
├── RESUME_TITAN.md              session handoff — read when resuming work
├── docs/
│   ├── MASTER.md                THIS FILE — the source of truth
│   ├── ARCHITECTURE.md          fixed design decisions
│   ├── XCELIUM_NOTES.md         bring-up log + 14 numbered quirks
│   ├── SETUP.md                 host setup detail
│   ├── VENDOR.md                submodule policy
│   ├── TRAINEE_GUIDE.md         cohort-facing walkthrough
│   └── earlgrey_block_diagram.svg
├── overlay/
│   ├── titan_sim_cfg.hjson      our dvsim config — where tests are registered
│   └── patches/                 local patches to vendor/ (a submodule can't carry them)
├── sw/trainee/                  trainee C tests + BUILD  (source of truth)
├── tests/smoke/                 trainee UVM vseqs + titan_vseq_list.sv
├── testplan/                    connectivity.md / integration.md / system.md
├── sim/
│   ├── run_xcelium.sh           main runner (auto-patches + auto-syncs)
│   ├── regress.sh               9-test smoke suite
│   ├── runs/                    symlinks to latest run dirs (gitignored)
│   └── scratch/                 dvsim build/run area (gitignored)
├── scripts/
│   ├── activate_env.{sh,csh}    per-session env
│   ├── setup_host_shims.sh      one-time host setup
│   ├── apply_vendor_patches.sh  idempotent patch application
│   └── sync_trainee_sw.sh       sw/trainee/ → vendor bazel package
└── vendor/opentitan/            pinned OT submodule (read-only + the one patch)
```

**Where things live**: C tests are authored in `sw/trainee/` and *synced* into
`vendor/opentitan/sw/device/tests/titan/` (an untracked bazel package) — always
edit the former.

---

## 11. Known quirks index

Full detail in [`docs/XCELIUM_NOTES.md`](XCELIUM_NOTES.md). The ones you are
most likely to hit:

| # | One-line symptom |
|---|---|
| 1 | SW build: `srec_cat: No such file` → pure-Python shim in `scripts/` |
| 3 | dvsim `UnicodeEncodeError` → needs `LANG=en_US.UTF-8` |
| 4 | FuseSoC parse errors → a stray `~/.local/bin/fusesoc` shadowing the venv's |
| 5 | `openssl/conf.h` not found → `CPATH` set by `activate_env.sh` |
| 10 | After a tool-mount change, `No rule to make target .../cassert` → purge the build dir |
| 11 | Clean build re-hits #5 → paths now resolved via `scripts/find_tools_root.sh` |
| **12** | `SVNOTY ... extends chip_sw_base_vseq` → the vendor patch is missing, or you tried `build_opts` |
| **13** | A run "passes" but the log is stale → `stat` it; `sim/runs/` is overwritten in place |
| **14** | `dKnown_A` / `dDataKnown_M` assertion → X from a floating pad on `dif_gpio_read_all()` |

---

## 12. Specifications & external links

### This project

- **Repo** — `git@github.com:auxeraglobaltech/titan-soc.git`
- **Pinned OpenTitan tree** — [github.com/lowrisc/opentitan @ `365c167e`](https://github.com/lowrisc/opentitan/tree/365c167ef632534a1282c780d8b990f46dfbccbf)

> ⚠️ The links below track upstream **HEAD**, not our pinned commit. For exact
> behaviour always read the RTL/docs under `vendor/opentitan/`. Use these for
> concepts and architecture, the local tree for detail.

### OpenTitan documentation

| Topic | Link |
|---|---|
| Documentation home | https://opentitan.org/book/ |
| Earl Grey top level | https://opentitan.org/book/hw/top_earlgrey/ |
| Earl Grey chip DV plan | https://opentitan.org/book/hw/top_earlgrey/data/chip_testplan.html |
| Ibex core | https://ibex-core.readthedocs.io/ |
| Security model | https://opentitan.org/book/doc/security/ |
| Life cycle controller | https://opentitan.org/book/hw/ip/lc_ctrl/ |
| Alert handler | https://opentitan.org/book/hw/ip/alert_handler/ |
| Key manager | https://opentitan.org/book/hw/ip/keymgr/ |
| Entropy source | https://opentitan.org/book/hw/ip/entropy_src/ |
| Flash controller | https://opentitan.org/book/hw/ip/flash_ctrl/ |
| GPIO | https://opentitan.org/book/hw/ip/gpio/ |
| RV PLIC | https://opentitan.org/book/hw/top_earlgrey/ip_autogen/rv_plic/ |
| DIF library | https://opentitan.org/book/sw/device/lib/dif/ |
| OTTF (test framework) | https://opentitan.org/book/sw/device/lib/testing/test_framework/ |
| DV methodology | https://opentitan.org/book/doc/contributing/dv/methodology/ |
| dvsim tool | https://opentitan.org/book/util/dvsim/ |

### Standards

| Topic | Link |
|---|---|
| TileLink (TL-UL) | https://www.sifive.com/documentation/tilelink/tilelink-spec/ |
| RISC-V ISA | https://riscv.org/technical/specifications/ |
| RISC-V debug | https://riscv.org/technical/specifications/ |
| UVM 1.2 reference | https://www.accellera.org/downloads/standards/uvm |
| IEEE 1800-2017 (SystemVerilog) | https://standards.ieee.org/standard/1800-2017.html |

### In-tree references worth bookmarking

| What | Path under `vendor/opentitan/` |
|---|---|
| All base addresses | `hw/top_earlgrey/sw/autogen/top_earlgrey.h` |
| Memory map | `hw/top_earlgrey/sw/autogen/top_earlgrey_memory.ld` |
| Chip DV config | `hw/top_earlgrey/dv/chip_sim_cfg.hjson` |
| Chip interface (all pins) | `hw/top_earlgrey/dv/env/chip_if.sv` |
| SW-test base vseq | `hw/top_earlgrey/dv/env/seq_lib/chip_sw_base_vseq.sv` |
| A worked paired vseq | `hw/top_earlgrey/dv/env/seq_lib/chip_sw_gpio_smoke_vseq.sv` |
| Upstream GPIO IRQ test | `sw/device/tests/sim_dv/gpio_test.c` |
| DIF headers | `sw/device/lib/dif/` |
| Xcelium tool config | `hw/dv/tools/dvsim/xcelium.hjson` |

---

## 13. Glossary

| Term | Meaning |
|---|---|
| **AON** | Always-On power domain; keeps running in deep sleep |
| **DIF** | Device Interface Function — OpenTitan's C register-access API (`dif_gpio_*`) |
| **dvsim** | OpenTitan's simulation build/run orchestrator |
| **Earl Grey** | The discrete-chip OpenTitan design; our DUT |
| **EDN** | Entropy Distribution Network — delivers entropy to consumers |
| **FuseSoC** | Package manager that resolves the RTL file list |
| **Ibex** | The 32-bit RISC-V core |
| **Life cycle** | Hardware-enforced chip states (`RAW`→`PROD`→`SCRAP`) gating debug |
| **OTP** | One-Time Programmable memory; fuses, keys, life cycle state |
| **OTTF** | OpenTitan Test Framework — the C harness (`test_main()`) |
| **RAL** | Register Abstraction Layer; UVM register model |
| **RoT** | Root of Trust |
| **TEST ROM** | Minimal boot ROM used in DV instead of the real ROM |
| **TL-UL** | TileLink Uncached Lightweight — the on-chip bus |
| **vseq** | Virtual sequence; the UVM half of a chip test |
| **`{self_dir}`** | dvsim variable = directory of the hjson being parsed |

---

*Maintained as the single source of truth. When something here goes stale, fix
it here first, then the detail pages.*
