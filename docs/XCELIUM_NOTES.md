# Xcelium Bring-up Notes — chip_sw_gpio_smoketest

Phase 3 target: get ONE existing OpenTitan chip-level smoke test fully prepared
to run on Cadence Xcelium, build all non-simulation collateral, and hand a
ready-to-run command to the human. **Claude Code never runs `xrun`.**

---

## Chosen test

| Item | Value | Source |
|------|-------|--------|
| Test name | `chip_sw_gpio_smoketest` | `hw/top_earlgrey/dv/chip_smoketests.hjson` |
| UVM sequence | `chip_sw_gpio_smoke_vseq` | same |
| SW test image | `//sw/device/tests:gpio_smoketest:1:new_rules` | same (Bazel label) |
| Boot | TEST ROM (`sw_test_mode_test_rom` run mode) | `chip_sim_cfg.hjson:368` |
| TEST ROM image | `//sw/device/lib/testing/test_rom:test_rom:0` | `chip_sim_cfg.hjson:369` |
| Sim cfg | `hw/top_earlgrey/dv/chip_sim_cfg.hjson` | — |
| Default tool | `vcs` (we override with `--tool xcelium`) | `chip_sim_cfg.hjson:18` |
| FuseSoC core | `lowrisc:dv:top_earlgrey_chip_sim:0.1` | `chip_sim_cfg.hjson:21` |

GPIO smoke is among the simplest chip tests: it boots through the TEST ROM, runs
a short DIF-based GPIO toggle, and reports status — no crypto, no entropy.

---

## Boot strategy (TEST ROM)

The test runs in `sw_test_mode_test_rom`, which injects the TEST ROM image into
the ROM memory (index 0 = `SwTypeROM`) and the gpio test into flash slot A
(index 1 = `SwTypeTestSlotA`). The TEST ROM brings the chip out of reset and
jumps to the flash test image. **No custom CRT0 / startup is written** — exactly
as required.

---

## Real chip memory map & test-status convention

Resolved from the tree at the pinned commit (NOT the Phase 2 trivial test).

### Memory map — `hw/top_earlgrey/sw/autogen/top_earlgrey_memory.ld`

| Region | Origin | Length | Role |
|--------|--------|--------|------|
| `rom` | `0x00008000` | `0x8000` (32 KiB) | TEST ROM loads here |
| `ram_main` | `0x10000000` | `0x20000` (128 KiB) | main SRAM |
| `eflash` | `0x20000000` | `0x100000` (1 MiB) | gpio test (slot A) loads here |
| `ram_ret_aon` | `0x40600000` | `0x1000` | retention SRAM |

### Test pass/fail — NOT spike `tohost`

Chip DV does **not** use the spike `tohost` convention used by the Phase 2
trivial test. Instead, the SW (OTTF test framework) writes a status word to a
fixed address in an *unmapped* window of the `rv_core_ibex` block; the testbench
monitors it through `sw_test_status_if` (bound to the sim SRAM in
`hw/top_earlgrey/dv/tb/tb.sv:404`).

Address derivation (`hw/top_earlgrey/dv/env/chip_common_pkg.sv:19-23`):

```
ADDR_SPACE_RV_CORE_IBEX__CFG     = 0x411f0000   (tl_main_pkg.sv)
RV_CORE_IBEX_DV_SIM_WINDOW_OFFSET = 0x80         (rv_core_ibex_reg_pkg.sv)

SW_DV_START_ADDR        = 0x411f0000 + 0x80 = 0x411f0080
SW_DV_TEST_STATUS_ADDR  = SW_DV_START_ADDR + 0  = 0x411f0080   <- pass/fail status
SW_DV_LOG_ADDR          = SW_DV_START_ADDR + 4  = 0x411f0084   <- SW log
```

So the chip's "tohost equivalent" is **`0x411f0080`**. The status values are the
`sw_test_status_t` enum (e.g. `kTestStatusInBootRom`, `kTestStatusInTest`,
`kTestStatusPassed`, `kTestStatusFailed`); the TB ends the sim on pass/fail.

---

## Software build (no xrun) — the OpenTitan-native path

> **Deviation from the literal task wording, with reason.** The task suggested
> "run gcc/objcopy yourself" for the SW images. That is feasible only for a
> trivial single-file program (Phase 2). The real `gpio_smoketest.c` is a full
> OTTF test that pulls in DIFs, the OTTF framework, device tables, the manifest,
> and the TEST ROM — its build is defined entirely by **Bazel** rules. The
> faithful, vendor-respecting way (Option B: reuse OT infra, never edit vendor)
> is to build via OpenTitan's Bazel flow, which internally drives a hermetic
> RISC-V toolchain. dvsim itself uses exactly this path
> (`hw/dv/tools/dvsim/bazel.hjson` → `build_sw_collateral_for_sim.py`).

SW prep replicates dvsim's `sw_build_cmd` exactly (run from `vendor/opentitan/`):

```bash
python util/py/scripts/build_sw_collateral_for_sim.py \
  --sw-images='//sw/device/lib/testing/test_rom:test_rom:0 //sw/device/tests:gpio_smoketest:1:new_rules' \
  --sw-build-opts='' \
  --sw-build-device=sim_dv \
  --seed=1 \
  --run-dir=<repo>/sim/runs/chip_sw_gpio_smoketest
```

This builds the TEST ROM + gpio test for the `sim_dv` device and deploys the
`.vmem`/`.bin`/`.elf`/`.scr.vmem` collateral into the run dir. (When the human
runs `sim/run_xcelium.sh`, dvsim performs this same step automatically; we run
it ahead of time to surface any SW build error before the simulation.)

> Note on toolchain: OpenTitan's Bazel build uses its own hermetic RISC-V
> toolchain, not `/home/user1/riscv/...`. The standalone prefix remains the tool
> for trainee thin-C tests (Phase 2 style); chip tests use the Bazel toolchain.

---

## Ready-to-run command (HUMAN runs this)

```bash
source scripts/activate_env.sh          # Python 3.11 venv (Phase 2.5)
# ensure xrun is on PATH
./sim/run_xcelium.sh                     # full build + run on Xcelium
# variants:
./sim/run_xcelium.sh --build-only        # stop after Xcelium elaboration
./sim/run_xcelium.sh --waves shm         # dump SHM waves (Xcelium native)
```

Underlying dvsim command:

```bash
dvsim hw/top_earlgrey/dv/chip_sim_cfg.hjson \
  -i chip_sw_gpio_smoketest \
  --tool xcelium \
  --local \
  --fixed-seed 1
```

---

## Troubleshooting table (Xcelium vs VCS)

Fixes go via **tool options** or **minimal, clearly-commented shims under
`overlay/`** — never by editing `vendor/`, never by disabling checks/assertions.

| # | Symptom / error | Root cause | Fix | Status |
|---|-----------------|-----------|-----|--------|
| 0 | (SW build) cold Bazel build downloads hermetic toolchain | first run only | none — expected; cached after first build | OK |
| 1 | SW build: `execvp(srec_cat,...): No such file or directory`; `srec_cat failed (Exit 1)`; "Build did NOT complete successfully"; run dir empty | OpenTitan Bazel rules call host `srec_cat` (from `srecord`, line 44 of `apt-requirements.txt`) as a **non-hermetic system tool** to convert `.bin`→`.vmem`. `srecord` is not installed on this host; no-sudo source build also blocked (boost + libgcrypt headers missing). | **RESOLVED** — pure-Python `srec_cat` shim implementing exactly the subset OT's `transform.bzl` invokes (`--binary --offset --byte-swap --fill/-within --vmem`). Committed at `scripts/srec_cat`; `activate_env.sh` prepends `scripts/` to PATH. SW collateral rebuilt successfully and deployed to `sim/runs/chip_sw_gpio_smoketest/` (`test_rom_sim_dv.*`, `gpio_smoketest_sim_dv.*`). | FIXED |
| 2 | (build tooling) missing `libtinfo.so.5` on RHEL9 during opentitantool/Bazel host-tool builds | RHEL9 ships `libtinfo.so.6` only | symlinked Xcelium's bundled copy: `ln -sf $XCELIUM/tools.lnx86/lib/64bit/RHEL/RHEL9/libtinfo.so.5 ~/.local/lib64/libtinfo.so.5` (machine-local; documented here for reproducibility) | FIXED |
| — | _(first Xcelium elaboration not yet attempted; rows added per round)_ | | | |

---

*Last updated: Phase 3 prep complete — test selected, memory map & test-status
resolved, srec_cat blocker fixed (shim in repo), SW collateral built and
deployed. Next: first Xcelium elaboration (`./sim/run_xcelium.sh --build-only`).*

> Note: `sim/runs/chip_sw_gpio_smoketest/sw_build.log` is stale (captures the
> pre-shim failure); the `.vmem`/`.elf` files beside it are from the successful
> post-shim rebuild.
