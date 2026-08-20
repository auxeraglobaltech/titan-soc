# RESUME — titan-soc session handoff

> Read this first when resuming — it is the *volatile* state (what just
> happened, what to do next). For stable reference — SoC description, memory
> map, commands, DV environment, how to add a test — see
> **[`docs/MASTER.md`](docs/MASTER.md)**, the single source of truth.
> Then `git log --oneline -10`. Last updated 2026-08-20.

---

## Pick a track first

This repo now carries **two independent work tracks**. Decide which one this
session is about before reading further.

| Track | Doc | Status | Next action |
|---|---|---|---|
| **SoC** — chip-level DV on Earl Grey | [`docs/SOC_WORK.md`](docs/SOC_WORK.md) | Phase 5, 9/9 smoke tests passing | Run `./sim/regress.sh` end to end (backlog #7) |
| **IP** — block-level DV playground | [`docs/IP_WORK.md`](docs/IP_WORK.md) | ✅ **23 IPs, all elaborating clean** (2026-08-20) | Assign IPs to engineers; curate the 17 generated READMEs |

The rest of this file is **SoC-track** state. IP-track state lives in
`docs/IP_WORK.md`.

---

## Where we are

**Phase 4 FULLY CLOSED** — `titan_sw_hello_test` confirmed PASSING by operator.

**Phase 5 item 2 CLOSED (2026-08-14)** — trainee vseq compile path **WORKS**.
`titan_sw_hello_test` 1/1 PASS, 125s runtime, UVM_ERROR 0, and critically the
sequencer instance is `uvm_test_top.env.virtual_sequencer.titan_hello_vseq`,
proving the trainee class was factory-registered and actually ran.

The original package re-open technique **does not work and was removed** —
see "vseq compile mechanism" below and quirk #12 in `docs/XCELIUM_NOTES.md`.

**ALL 4 TRAINEE TESTS PASSING (2026-08-14)** — and the repo is now
clone-and-run. Phase 5 items 1–5 are done.

| Test | Kind | Result |
|------|------|--------|
| `titan_sw_hello_test` | C + vseq | ✅ 1/1, 125s |
| `titan_sw_gpio_irq_test` | C + vseq (INT-3) | ✅ 1/1, 171s, 8 edges / 8 IRQs |
| `titan_sw_gpio_out_selfcheck_test` | C only (CONN-2a) | ✅ 1/1, 168s |
| `titan_sw_rv_timer_irq_test` | C only (INT-1a) | ✅ 1/1, 168s |

`sim/regress.sh` now covers all 9 tests (5 upstream + 4 trainee).

**Setup is automatic.** `sim/run_xcelium.sh` calls
`scripts/apply_vendor_patches.sh` and `scripts/sync_trainee_sw.sh` on every
invocation, both idempotent. You no longer need to sync SW by hand, and a
fresh clone self-heals the vendor patch. Verified by reverting the vendor file
and re-running.

**Next operator action**: run the full regression to confirm nothing regressed,
then pick up the remaining backlog.

```csh
source scripts/activate_env.csh
./sim/regress.sh
```

Verify (csh — note `set L = ...`, and no `#` comments; csh has none
interactively and an apostrophe will open a quote):
```csh
set L = sim/runs/<test>/run.log
stat -c "%y" $L
grep -E "^UVM_(ERROR|FATAL) :" $L
grep -E "TEST (PASSED|FAILED)" $L
```

---

## vseq compile mechanism (Phase 5 item 2) — SETTLED

**Technique in use**: guarded `` `include `` inside the vendor vseq list.

`vendor/.../dv/env/seq_lib/chip_vseq_list.sv` ends with a 3-line hook:

```systemverilog
`ifdef TITAN_VSEQ_EXTRAS
  `include "titan_vseq_list.sv"
`endif
```

`tests/smoke/titan_vseq_list.sv` lists the trainee vseqs. Two `build_opts` in
`overlay/titan_sim_cfg.hjson` turn it on:

```hjson
build_opts: [
  "+incdir+{self_dir}/../tests/smoke"
  "+define+TITAN_VSEQ_EXTRAS"
]
```

**To add a vseq**: drop `<name>_vseq.sv` in `tests/smoke/`, add one `` `include ``
line to `titan_vseq_list.sv`, set `uvm_test_seq: <name>_vseq` in the overlay.
No vendor change needed — the hook is already there.

⚠️ **This is the one sanctioned `vendor/` edit**, and it is NOT captured by any
titan-soc commit — `vendor/opentitan` is a submodule, so the edit shows only as
a dirty-submodule marker and its content lives nowhere in this repo. It is
therefore saved as **`overlay/patches/0001-titan-vseq-hook.patch`**.

Check it is still applied (do this first if a vseq test suddenly fails to
compile with `SVNOTY`):
```csh
git -C vendor/opentitan status --short
```
Re-apply after a submodule bump / re-clone / clean:
```csh
git -C vendor/opentitan apply $PWD/overlay/patches/0001-titan-vseq-hook.patch
```
See `overlay/patches/README.md`.

### Why the previous approach was abandoned (do not retry)

Package re-open (`overlay/titan_vseq_extras.sv`, deleted) failed for **two
independent reasons** — full detail in quirk #12 of `docs/XCELIUM_NOTES.md`:

1. **Ordering**: dvsim emits overlay `build_opts` *before* `-f {sv_flist}`
   (`hw/dv/tools/dvsim/xcelium.hjson:10-17`), so any `.sv` added via
   `build_opts` compiles before `chip_env_pkg` exists. **No `build_opts`-based
   approach can work** — this also kills the old "separate `titan_env_pkg`"
   fallback, so don't reach for it.
2. **Imports are per package-block**: re-opening a package appends identifiers
   but inherits none of the first block's ~40 imports
   (`chip_env_pkg.sv:8-40`), so even `` `uvm_object_utils `` fails.

Being included inside the original package block fixes both at once.

---

## Phase 5 backlog (updated order)

1. ✅ **Close Phase 4**: done — hello_test PASSING
2. ✅ **Validate vseq compile**: done 2026-08-14 via guarded include (not package re-open)
3. ✅ **First trainee test**: `titan_sw_gpio_irq_test` (INT-3) — PASSING 2026-08-14
4. ✅ **C-only trainee tests**: both PASSING 2026-08-14
   - `titan_sw_gpio_out_selfcheck_test` (CONN-2a) — GPIO output loopback, self-checked
   - `titan_sw_rv_timer_irq_test` (INT-1a) — 5 timer deadlines, one IRQ each
5. ✅ **regress.sh**: all 4 trainee tests added (9 total)
6. ✅ **Clone-and-run**: `run_xcelium.sh` auto-applies vendor patches + syncs SW

### Remaining

7. **Run `./sim/regress.sh` end to end** — the 9-test set has never been run as
   a whole; individual passes are confirmed but the suite is not.
8. **INT-4**: UART RX watermark IRQ (C+UVM pair) — designed in
   `testplan/integration.md`, not written.
9. **Pure-UVM tests**: still zero. Needs the stub-CPU path
   (`chip_stub_cpu_base_vseq`), a different lift from the SW-driven flow —
   scope it before promising it.
10. Coverage closure pass (`COV=1 ./sim/regress.sh`), merge in IMC.
11. Feasibility check: `chip_sw_pwrmgr_smoketest` (SYS-1).

---

## Facts that keep getting re-derived (don't re-derive)

- Bus topology: `spi_host0/1` + `usbdev` on **xbar_main**; `rv_timer` on **xbar_peri**. 44 module instances total.
- All registered tests are **C tests** (OTTF, tohost/status-word); zero pure-UVM tests yet.
- A test entry with **no** `uvm_test_seq` inherits `chip_sw_base_vseq` (`chip_sim_cfg.hjson:158`) — that is how the C-only trainee tests run without a vseq.
- Live tree is **top_earlgrey** (not darjeeling); its `chip_sw_gpio_smoke_vseq` uses `SwTypeTestSlotA`, the darjeeling copy uses `SwTypeCtn`. `NUM_GPIOS = 32` (`chip_common_pkg.sv:11`).
- `pins_if.drive(val)` asserts OE on **all** pins — use `drive_pin(i, val)` to touch only the pins you own.
- Never trust `sim/runs/<test>/run.log` without `stat`-ing it first: it is overwritten in place, so a build failure leaves the *previous* run's log looking valid (quirk #13).
- gpio smoketest has active vseq partner (`chip_sw_gpio_smoke_vseq` backdoor-injects `kGpioVals`).
- hjson sanity: parse with `.venv/bin/python3 -c "import hjson; hjson.load(open('overlay/titan_sim_cfg.hjson'))"`
- `{self_dir}` in hjson = directory of the hjson being parsed — confirmed in dvsim `flow/factory.py:40`.

## Hard rules (never break)

- **Never invoke `xrun`/dvsim sims from automation** — print commands, operator runs them.
- `vendor/opentitan/` is read-only (untracked additions in `sw/device/tests/titan/` only).
- Project code in `overlay/`, `sw/trainee/`, `tests/`; sync SW with `./scripts/sync_trainee_sw.sh`.
- Keep `./sim/regress.sh` green before pushing; one xrun at a time on shared server.

## Session log (2026-07-08, session 2)

- Phase 4 closed: operator confirmed `titan_sw_hello_test` PASSING.
- Investigated vseq compile mechanism: discovered `chip_env_pkg` uses
  `is_include_file: true` for all vseqs → package re-open technique chosen.
- Confirmed `{self_dir}` dvsim variable from `dvsim/flow/factory.py:40`.
- Created `overlay/titan_vseq_extras.sv` (re-opens pkg, includes trainee vseqs).
- Updated `titan_sim_cfg.hjson`: build_opts for incdir + extras file; switched
  `titan_sw_hello_test` to `uvm_test_seq: titan_hello_vseq`.
- Documented mechanism in `tests/smoke/README.md`. → commit `9b91d9e`
