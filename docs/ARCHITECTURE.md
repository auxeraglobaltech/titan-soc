# titan-soc Architecture

This document records the fixed **design decisions** for titan-soc. Changes to
any item here require explicit team agreement.

> 📖 For everything else — status, commands, memory map, SoC description, DV
> environment internals, how to add a test — see
> **[`docs/MASTER.md`](MASTER.md)**, the single source of truth. This page is
> the "why we decided X" record only.

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

> **Revised in Phase 3–5.** The original decision (raw register offsets, spike
> `tohost`, `sw/tests/`) did not survive contact with the real chip: the TEST
> ROM boot path requires the OTTF, and the OTTF brings the DIFs and the status
> word with it. Recorded here rather than silently rewritten, because the
> original wording still appears in older notes.

- **Thin bare-metal C on the OTTF** (OpenTitan Test Framework):
  `OTTF_DEFINE_TEST_CONFIG();` plus `bool test_main(void)`.
- **DIFs are used**, not raw offsets — `dif_gpio_*`, `dif_rv_plic_*`, etc.
  Hand-rolling register access on this chip means re-deriving integrity and
  multi-register sequencing that the DIFs already get right.
- Tests are one `.c` file per scenario under **`sw/trainee/`** (synced into the
  vendor bazel tree by `scripts/sync_trainee_sw.sh`).
- Pass condition: **return `true` from `test_main()`**, which the OTTF turns
  into `SwTestStatusPassed` at the status word `0x411f0080`. This is the chip's
  `tohost` equivalent — the spike `tohost` convention is **not** used at chip
  level. See `docs/MASTER.md` §6.


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
| `vendor/` | **Read-only, with one sanctioned exception (below).** Treat as upstream source. |
| `overlay/` | **Our code.** All project-specific changes, additions, and patches live here. |

The build system layers `overlay/` on top of `vendor/` so that overlay files take
precedence. This keeps the vendor tree clean for straightforward upstream upgrades.

> **If you find yourself editing a file under `vendor/`, stop.**  
> Copy the relevant piece into the matching path under `overlay/` instead.

### 3.1 The one sanctioned vendor edit

Approved 2026-08-14 after the alternatives were shown to be impossible.

Trainee vseqs must be compiled *inside* `chip_env_pkg` to subclass
`chip_sw_base_vseq`, and dvsim emits `build_opts` **before** `-f {sv_flist}` —
so nothing added via `build_opts` can ever see that package. A 16-line guarded
`` `ifdef TITAN_VSEQ_EXTRAS `` include at the end of
`hw/top_earlgrey/dv/env/seq_lib/chip_vseq_list.sv` is the only working hook. It
is inert without the define, so upstream builds are unaffected.

Because `vendor/opentitan` is a **submodule**, this repo cannot store that edit;
it is kept as `overlay/patches/0001-titan-vseq-hook.patch` and re-applied
automatically by `sim/run_xcelium.sh`. Consequence: `git status` permanently
shows ` m vendor/opentitan`, and that is expected, not dirt.

Full reasoning: quirk #12 in `docs/XCELIUM_NOTES.md`; `docs/MASTER.md` §7.4.

Any *further* vendor edit needs the same bar: demonstrate no overlay-side
mechanism exists, then add a patch file — never an unrecorded in-place edit.

---

## 4. Phase plan summary

Superseded by the 6-phase plan in `README.md` and `docs/MASTER.md` §3, which is
the current one. Kept for history:

| Phase | Deliverable (original Phase-0 plan) |
|-------|------------|
| 0 | Repo skeleton, architecture doc, README |
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

*Last updated: 2026-08-14 — §2.5 revised to match the OTTF/DIF reality, §3.1
added for the sanctioned vendor patch, §4 superseded. Current status and
everything operational: [`docs/MASTER.md`](MASTER.md).*
