# titan-soc

SystemVerilog/UVM SoC verification **training environment** for the
[OpenTitan Earl Grey](https://opentitan.org/) SoC, targeting **Cadence Xcelium**.

This repo is the SoC-level companion to **Training-FE** (Ibex core DV). Structure
and workflow conventions are kept recognizably similar between the two.

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
./sim/run_xcelium.sh --waves shm                       # with SHM waves
./sim/run_xcelium.sh --build-only                      # elaborate only

# 5. Results — never dig inside vendor/:
less sim/runs/latest/run.log            # main UVM log of the newest run
simvision sim/runs/latest/waves.shm &   # waves (if dumped)
```

Both `chip_sw_gpio_smoketest` and `chip_sw_uart_smoketest` pass 1/1 on
Xcelium. Bring-up history and every host quirk fixed along the way:
[`docs/XCELIUM_NOTES.md`](docs/XCELIUM_NOTES.md).

---

## Directory layout

```
titan-soc/
├── vendor/          # Third-party sources (OpenTitan submodule — Phase 1)
│                    #   READ-ONLY. Never edit here.
├── overlay/         # Our overrides/extensions layered on top of vendor/
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
| **4** | Trainee tests & testplan; coverage; regression suite | ← *next* |

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

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for full rationale.
