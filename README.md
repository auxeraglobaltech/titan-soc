# titan-soc

SystemVerilog/UVM SoC verification **training environment** for the
[OpenTitan Earl Grey](https://opentitan.org/) SoC, targeting **Cadence Xcelium**.

This repo is the SoC-level companion to **Training-FE** (Ibex core DV). Structure
and workflow conventions are kept recognizably similar between the two.

> 📖 **[`docs/MASTER.md`](docs/MASTER.md) is the single source of truth** —
> what the SoC is, current status, every command, memory map, DV environment,
> how to add a test, spec links and glossary. This README is the short version.

---

## Two work tracks

| Track | Doc | What you do | Status |
|---|---|---|---|
| **SoC** | [`docs/SOC_WORK.md`](docs/SOC_WORK.md) | Chip-level DV on Earl Grey — C tests on Ibex + UVM vseqs, reusing the upstream env | Phase 5, 9/9 smoke tests passing |
| **IP** | [`docs/IP_WORK.md`](docs/IP_WORK.md) | Block-level DV — one IP, real RTL + spec, build the whole UVM env yourself | 🔲 planned |

New to both? Start on the **IP track** — the feedback loop is seconds instead
of minutes, and chip-level debug assumes you already trust the blocks.
[`RESUME_TITAN.md`](RESUME_TITAN.md) routes between the two.

---

## Purpose

Trainees learn chip-level verification by:

1. Writing **UVM test cases** (in `tests/`) that extend the OpenTitan DV
   environment reused verbatim from upstream.
2. Writing **thin bare-metal C programs** (in `sw/`) that exercise hardware
   features via direct register access, using a `tohost` pass/fail convention.
3. Running simulations on a real SoC RTL model (OpenTitan Earl Grey) with a
   full UVM environment — not a toy design.

The heavy DV infrastructure (UVM agents, environments, scoreboards) is **not
re-implemented** here. Trainees extend it. This is **Option B** — see
`docs/ARCHITECTURE.md`.

---

## Quick-start

```csh
# 1. Clone with submodules
git clone --recurse-submodules git@github.com:auxeraglobaltech/titan-soc.git
cd titan-soc

# 2. One-time host setup (dev-symlink/pkg-config/libftdi shims, no sudo needed)
./scripts/setup_host_shims.sh

# 3. Activate the environment (venv + Cadence tools + Bazel site config)
source scripts/activate_env.csh     # csh/tcsh users
source scripts/activate_env.sh      # bash users

# 4. Run a chip-level test (default: chip_sw_gpio_smoketest)
./sim/run_xcelium.sh
env TEST=chip_sw_uart_smoketest ./sim/run_xcelium.sh   # pick another test
env TEST=titan_sw_gpio_irq_test ./sim/run_xcelium.sh   # a trainee test
./sim/run_xcelium.sh --waves shm                       # with SHM waves
./sim/run_xcelium.sh --build-only                      # elaborate only

# 5. Results — never dig inside vendor/:
less sim/runs/latest/run.log            # main UVM log of the newest run
simvision sim/runs/latest/waves.shm &   # waves (if dumped)

# 6. Full smoke regression (9 tests, serial — takes a while)
./sim/regress.sh
```

Nothing else is needed: `run_xcelium.sh` re-applies the vendor patches
(`overlay/patches/`) and syncs `sw/trainee/` on every invocation, both
idempotent. Bring-up history and every host quirk fixed along the way:
[`docs/XCELIUM_NOTES.md`](docs/XCELIUM_NOTES.md).

---

## Tests

All **9** pass 1/1 on Xcelium (2026-08-14).

| Test | Kind | Plan | What it proves |
|------|------|------|----------------|
| `chip_sw_gpio_smoketest` | upstream | CONN-2 | GPIO pads reach the TB |
| `chip_sw_uart_smoketest` | upstream | CONN-3 | UART TX/RX to the DV agent |
| `chip_sw_rv_timer_smoketest` | upstream | INT-1 | timer IRQ to Ibex |
| `chip_sw_aon_timer_smoketest` | upstream | INT-2 | AON wakeup/watchdog |
| `chip_sw_sram_ctrl_smoketest` | upstream | CONN-4 | main + retention SRAM |
| `titan_sw_hello_test` | trainee, C + vseq | CONN-5 | the trainee workflow end to end |
| `titan_sw_gpio_irq_test` | trainee, C + vseq | INT-3 | GPIO edge → PLIC → ISR; 8 edges, 8 IRQs |
| `titan_sw_gpio_out_selfcheck_test` | trainee, C only | CONN-2a | GPIO output loopback, self-checked |
| `titan_sw_rv_timer_irq_test` | trainee, C only | INT-1a | 5 timer deadlines, one IRQ each |

### Adding a trainee test

**C only** (no testbench interaction) — inherits the default
`chip_sw_base_vseq`:

1. `sw/trainee/<name>.c` + an `opentitan_test()` in `sw/trainee/BUILD`
2. one entry in `overlay/titan_sim_cfg.hjson`, with **no** `uvm_test_seq`

**C + UVM pair** (the testbench must drive or observe something) — two more
steps:

3. `tests/smoke/<name>_vseq.sv`, plus one `` `include `` in
   `tests/smoke/titan_vseq_list.sv`
4. set `uvm_test_seq: <name>_vseq` on the test entry

Then `env TEST=<name> ./sim/run_xcelium.sh`. See `docs/TRAINEE_GUIDE.md`.

> **Why trainee vseqs go through `titan_vseq_list.sv`**: every upstream vseq
> lives *inside* `chip_env_pkg`, and dvsim emits `build_opts` before
> `-f {sv_flist}` — so a vseq added via `build_opts` compiles before that
> package exists and cannot see `chip_sw_base_vseq`. The only working hook is a
> guarded `` `include `` at the end of the vendor `chip_vseq_list.sv`, stored in
> `overlay/patches/` and re-applied automatically. Full reasoning: quirk #12 in
> [`docs/XCELIUM_NOTES.md`](docs/XCELIUM_NOTES.md).

---

## Directory layout

```
titan-soc/
├── vendor/          # Third-party sources (OpenTitan submodule — Phase 1)
│                    #   READ-ONLY, except the patches in overlay/patches/,
│                    #   which run_xcelium.sh re-applies automatically.
├── overlay/         # Our overrides/extensions layered on top of vendor/
│   └── patches/     #   Local patches to vendor/ (a submodule cannot carry
│                    #   them) — see overlay/patches/README.md
├── tests/           # Trainee UVM test classes
├── sw/              # Trainee thin bare-metal C test programs
├── testplan/        # Connectivity / integration / system test plans
├── sim/             # Xcelium run scripts and run directories
└── docs/            # Project documentation
    └── ARCHITECTURE.md
```

---

## Phase plan

| Phase | Goal | Status |
|-------|------|--------|
| **0** | Repo skeleton, architecture decisions recorded | ✅ done |
| **1** | OpenTitan submodule pinned; elaboration with Xcelium verified | ✅ done |
| **2** | Build prerequisites, toolchain, Python env | ✅ done |
| **3** | First chip tests passing on Xcelium (gpio + uart smoke, 1/1) | ✅ done |
| **4** | Trainee tests & testplan; coverage; regression suite (5-test smoke green) | ✅ done |
| **5** | Trainee vseq compile path validated; first cohort exercises (INT-3, CONN-2a, INT-1a passing); coverage closure | ← *in progress* |

---

## Key facts

| Item | Value |
|------|-------|
| DV approach | Option B — reuse OpenTitan DV infra |
| Simulator | Cadence Xcelium (`xrun`) |
| OpenTitan commit | `365c167ef632534a1282c780d8b990f46dfbccbf` |
| RISC-V toolchain | `/home/user1/riscv/bin/riscv32-unknown-elf-` |
| C test style | Thin bare-metal, `tohost` convention, no DIFs |
| Boot strategy | OpenTitan TEST ROM (no hand-written startup) |

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for full rationale, and
[`docs/earlgrey_block_diagram.svg`](docs/earlgrey_block_diagram.svg) for the
annotated Earl Grey block diagram (bus topology from the pinned commit's
`xbar_{main,peri}.hjson`; smoke-verified IPs marked ✓).
