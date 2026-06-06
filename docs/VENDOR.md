# Vendor Component Reference

Components from `vendor/opentitan/` that titan-soc reuses without modification.
**Do not edit any file listed here.** Project-specific changes go in `overlay/`.

Pinned commit: `365c167ef632534a1282c780d8b990f46dfbccbf` (2026-06-04)

---

## 1. TL-UL UVM Agent

**Path:** `vendor/opentitan/hw/dv/sv/tl_agent/`

The Tile-Link Uncached Lightweight (TL-UL) bus functional model. Provides a
complete UVM agent (driver, monitor, sequencer, coverage) for the on-chip
interconnect fabric.

Key files:
- `tl_agent.sv` — top-level agent
- `tl_agent_cfg.sv` — configuration object
- `tl_agent_pkg.sv` — package import
- `tl_agent.core` — FuseSoC core descriptor

Trainees instantiate sequences against this agent's sequencer to generate
register and memory traffic.

---

## 2. CIP Base Library

**Path:** `vendor/opentitan/hw/dv/sv/cip_lib/`

Comportable IP (CIP) base classes: `cip_base_env`, `cip_base_env_cfg`,
`cip_base_scoreboard`, `cip_base_test`, `cip_base_virtual_sequencer`.

Every IP-level and chip-level UVM environment in OpenTitan extends these classes.
Trainee test environments inherit from them via the chip env (see §4).

Key files:
- `cip_base_env.sv`
- `cip_base_env_cfg.sv`
- `cip_base_scoreboard.sv`
- `cip_base_test.sv`
- `cip_lib.core`

---

## 3. Chip-Level RAL (Register Abstraction Layer)

**Path:** `vendor/opentitan/hw/top_earlgrey/dv/env/`

FuseSoC core descriptor: `chip_ral.core`

The chip-level RAL gives UVM tests a typed, address-mapped view of every
register in the Earl Grey SoC. It is auto-generated from the IP Hjson register
descriptions; do not hand-edit the generated files.

Supporting autogen file:
- `env/autogen/chip_env_pkg__params.sv` — address parameters used by the RAL

---

## 4. Chip DV Testbench

**Path:** `vendor/opentitan/hw/top_earlgrey/dv/`

The complete chip-level DV environment and testbench.

| Sub-path | Contents |
|----------|---------|
| `tb/tb.sv` | Testbench top — DUT instantiation, clocks, resets |
| `env/chip_env.sv` | Chip UVM environment |
| `env/chip_env_cfg.sv` | Environment configuration |
| `env/chip_env_pkg.sv` | Package (imports all agents, RAL, etc.) |
| `tests/` | OpenTitan's own chip test classes (trainee tests extend these) |
| `chip_sim_cfg.hjson` | dvsim simulation configuration |
| `chip_sim.core` | FuseSoC elaboration descriptor |

Trainee UVM tests in `tests/` of this repo extend classes from
`vendor/opentitan/hw/top_earlgrey/dv/tests/`.

---

## 5. dvsim

**Path:** `vendor/opentitan/util/dvsim/`

OpenTitan's simulation management framework. Parses `.hjson` sim-cfg files,
manages compile/run/coverage flows, and aggregates results.

The chip entry point is:
`vendor/opentitan/hw/top_earlgrey/dv/chip_sim_cfg.hjson`

> **Note:** dvsim targets the internal OpenTitan build system (Bazel/FuseSoC).
> For Phase 1 we drive Xcelium directly via scripts in `sim/`; dvsim integration
> is a Phase 2+ consideration.

---

## 6. TEST ROM (Boot Image)

**Path:** `vendor/opentitan/sw/device/lib/testing/test_rom/`

Minimal ROM image that initializes the Earl Grey chip out of reset and jumps
to a test payload in SRAM. Trainees rely on this for all C-test boot; they do
not write startup code.

Key files:
| File | Role |
|------|------|
| `test_rom_start.S` | Reset vector, stack setup, `.bss` clear, call to `test_rom_main` |
| `test_rom.c` | Minimal `test_rom_main`: UART init, load test image, jump |
| `test_rom.ld` | Linker script placing ROM at its fixed address |
| `test_rom_test.c` | Upstream unit test (not used by trainees) |

The TEST ROM is pre-built and loaded into simulation by the chip testbench;
trainees supply only the SRAM payload (their `.c` test compiled to a `.bin`).

---

*This file is a reference only. No files under `vendor/` are modified by this project.*
