# titan-soc Architecture

This document records all fixed design decisions for the titan-soc training
environment. Changes to any item here require explicit team agreement.

---

## 1. Project overview

**titan-soc** is a SystemVerilog/UVM SoC verification training environment built
around the **OpenTitan Earl Grey** SoC. It is the SoC-level sibling of the
**Training-FE** repo (Ibex core DV); directory structure and workflow conventions
are kept recognizably similar.

Trainees verify the Earl Grey chip by writing UVM test cases and thin bare-metal C
programs. The heavy DV infrastructure (agents, environments, scoreboards, sequences)
is reused verbatim from OpenTitan upstream; trainees extend it, not replace it.

---

## 2. Fixed decisions

### 2.1 DV infrastructure approach

**Option B — reuse OpenTitan DV infra; trainees write only test cases.**

- The OpenTitan repo ships a complete UVM environment for Earl Grey
  (`hw/top_earlgrey/dv/`).  
- Trainees extend that environment: they write new UVM test classes in `tests/`
  and thin C programs in `sw/`.  
- No re-implementation of agents, monitors, or scoreboards unless there is a
  specific training objective that requires it.

### 2.2 Target simulator

**Cadence Xcelium** (`xrun`).

- All scripts under `sim/` are written for Xcelium.
- **Automation (Claude Code, CI) MUST NOT invoke `xrun`.**  
  Scripts are prepared and printed; a human operator runs them.

### 2.3 Pinned OpenTitan commit

| Field | Value |
|-------|-------|
| Hash | `365c167ef632534a1282c780d8b990f46dfbccbf` |
| Date | 2026-06-04 17:32:08 UTC |
| Subject | `ujson: Workaround nested-type byte-tracking bug` |
| Submodule path | `vendor/opentitan/` |

- Submodule added in Phase 1; HEAD is detached at this exact hash.
- The commit is pinned to ensure reproducibility. Upgrades are explicit and
  reviewed.

### 2.4 RISC-V toolchain

Prefix: `/home/user1/riscv/bin/riscv32-unknown-elf-`  
(pre-installed on the training workstation; not vendored in this repo)

Relevant binaries:
- `riscv32-unknown-elf-gcc`
- `riscv32-unknown-elf-objcopy`
- `riscv32-unknown-elf-nm`

### 2.5 C test style

- **Thin bare-metal C** with a `tohost` pass/fail convention.
- **No DIF layer.** Trainees access registers directly using offsets from the
  chip memory map.
- Tests are one `.c` file per scenario under `sw/tests/`.
- Pass condition: write `1` (non-zero) to the `tohost` symbol before returning.
- Fail condition: write `0` to `tohost`, or loop indefinitely.


### 2.6 Boot strategy

**Use OpenTitan's TEST ROM** to bring the chip out of reset.

- The TEST ROM performs minimal hardware initialization and then jumps to the
  test payload loaded into SRAM.
- Trainees do NOT write CRT0 / chip startup code.
- TEST ROM source path in the vendor tree:
  `vendor/opentitan/sw/device/lib/testing/test_rom/`  
  Key files: `test_rom.c`, `test_rom_start.S`, `test_rom.ld`

---

## 3. Vendor vs overlay rule

| Tree | Rule |
|------|------|
| `vendor/` | **Read-only.** Never edit files here. Treat as upstream source. |
| `overlay/` | **Our code.** All project-specific changes, additions, and patches live here. |

The build system layers `overlay/` on top of `vendor/` so that overlay files take
precedence. This keeps the vendor tree clean for straightforward upstream upgrades.

> **If you find yourself editing a file under `vendor/`, stop.**  
> Copy the relevant piece into the matching path under `overlay/` instead.

---

## 4. Phase plan summary

| Phase | Deliverable |
|-------|------------|
| 0 | Repo skeleton, architecture doc, README (this phase) |
| 1 | OpenTitan submodule pinned; FuseSoC / Xcelium elaboration verified |
| 2 | First trainee UVM tests and C programs running; testplan populated |
| 3 | Coverage closure, regression suite, training exercises documented |

---

## 5. Relationship to Training-FE

Training-FE targets the **Ibex** core in isolation (block-level DV).  
titan-soc targets the **Earl Grey** chip (SoC-level DV).

Both repos share:
- Option B philosophy (reuse upstream DV infra)
- Cadence Xcelium as simulator
- Thin C test style with tohost convention
- `vendor/` + `overlay/` split

---

*Last updated: Phase 1 — OpenTitan submodule pinned.*
