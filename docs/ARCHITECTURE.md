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

```
365c167ef632534a1282c780d8b990f46dfbccbf
```

- The submodule is added at `vendor/opentitan/` in Phase 1.
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

<!-- TODO: confirm exact tohost symbol name and address from OpenTitan memory map
     once vendor submodule is added -->

### 2.6 Boot strategy

**Use OpenTitan's TEST ROM** to bring the chip out of reset.

- The TEST ROM performs minimal hardware initialization and then jumps to the
  test payload loaded into SRAM.
- Trainees do NOT write CRT0 / chip startup code.
- The TEST ROM path in the vendor tree is:
  <!-- TODO: confirm path — expected near
       vendor/opentitan/sw/device/lib/testing/test_framework/
       or vendor/opentitan/sw/device/silicon_creator/rom/ -->

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

*Last updated: Phase 0 — repo skeleton.*
