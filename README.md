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

## Quick-start (Phase 1+)

> Phase 0 only sets up the skeleton. Simulation commands will be added in Phase 1
> once the OpenTitan submodule is populated.

```bash
# 1. Clone with submodules (Phase 1+)
git clone --recurse-submodules https://github.com/auxeraglobaltech/titan-soc.git
cd titan-soc

# 2. Elaborate (human runs this — automation must not invoke xrun directly)
#    TODO: add command after Phase 1

# 3. Run a test
#    TODO: add command after Phase 1
```

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

| Phase | Goal |
|-------|------|
| **0** | Repo skeleton, architecture decisions recorded ← *you are here* |
| **1** | OpenTitan submodule pinned; elaboration with Xcelium verified |
| **2** | First trainee tests running; test plan populated |
| **3** | Coverage closure, regression suite, training exercises |

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
