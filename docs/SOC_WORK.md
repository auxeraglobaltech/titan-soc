# SoC Work — chip-level DV track

> One of two work tracks in this repo. The other is
> **[IP_WORK.md](IP_WORK.md)** (block-level DV on individual IPs).
> When resuming, read [RESUME_TITAN.md](../RESUME_TITAN.md) first — it says
> which track is active.

**Goal**: chip-level DV on OpenTitan Earl Grey. Reuse the upstream UVM
environment wholesale; author only test content — C programs that run on the
Ibex core, and UVM virtual sequences that drive the chip's pins.

**Full reference**: **[MASTER.md](MASTER.md)** is the single source of truth for
this track — architecture, memory map, commands, how a test works, quirks. This
file is only the *work queue*.

**Status**: Phase 5 in progress. 9/9 smoke tests passing (2026-08-14).

---

## 1. Where this track stands

| Phase | Goal | Status |
|---|---|---|
| 0 | Repo skeleton, architecture decisions | ✅ |
| 1 | OT submodule pinned; Xcelium elaboration verified | ✅ |
| 2 | Toolchain, Python env, build prerequisites | ✅ |
| 3 | First chip tests passing (gpio + uart smoke) | ✅ |
| 4 | Testplans, regression suite, trainee workflow | ✅ |
| 5 | Trainee vseq path; cohort exercises; coverage closure | 🔄 |

Nine tests pass individually — 5 upstream smoke + 4 trainee-authored. The test
table, runtimes and what each one proves are in
[MASTER.md §3](MASTER.md#3-current-status).

---

## 2. Backlog

Items 1–6 of Phase 5 are closed (see [RESUME_TITAN.md](../RESUME_TITAN.md) for
the detail). What remains:

| # | Item | Size | Notes |
|---|---|---|---|
| 7 | **Run `./sim/regress.sh` end to end** | small | The 9-test suite has never run as a whole. Individual passes confirmed; suite pass/fail logic was changed recently and is unproven. **Do this first** — it gates everything else. |
| 8 | **INT-4: UART RX watermark IRQ** | medium | C + UVM pair. Designed in [`testplan/integration.md`](../testplan/integration.md), not written. The natural next trainee test. |
| 9 | **First pure-UVM test** | large | Still zero. Needs the stub-CPU path (`chip_stub_cpu_base_vseq`) — a different lift from the SW-driven flow. **Scope it before promising it.** |
| 10 | **Coverage closure** | medium | `COV=1` works but there is no merged report. Needs a `COV=1 ./sim/regress.sh` run and an IMC merge. |
| 11 | **SYS-1 feasibility**: `chip_sw_pwrmgr_smoketest` | unknown | Deep sleep / wakeup. Needs a timing + entropy feasibility check on Xcelium; may be hours per run. |

Longer-range candidates live in [`testplan/system.md`](../testplan/system.md):
watchdog-bite reset (SYS-2), multi-IP concurrent soak (SYS-3), and the security
scenarios — alert escalation, life-cycle transitions.

---

## 3. Resuming this track

```csh
source scripts/activate_env.csh
which dvsim xrun
./sim/regress.sh
```

Then verify — note csh syntax, and **always `stat` the log first** because
`sim/runs/<test>/` is overwritten in place (quirk #13):

```csh
set L = sim/runs/<test>/run.log
stat -c "%y" $L
grep -E "^UVM_(ERROR|FATAL) :" $L
grep -E "TEST (PASSED|FAILED)" $L
```

Adding a test, reading failures, and the full command set:
[MASTER.md §4](MASTER.md#4-commands--everything-you-can-run) and
[§9](MASTER.md#9-adding-your-own-test).

---

## 4. Hard rules for this track

- **Never invoke `xrun`/dvsim from automation** — print the command, the
  operator runs it.
- **One simulation at a time** — shared server. Check `who` first.
- `vendor/opentitan/` is read-only. The single sanctioned edit is the vseq hook
  patch, auto-applied by `run_xcelium.sh`
  ([MASTER.md §7.4](MASTER.md#74-the-one-vendor-patch)). ` m vendor/opentitan`
  in `git status` is expected, permanently.
- Project code lives in `overlay/`, `sw/trainee/`, `tests/`. Edit
  `sw/trainee/` — never the synced copy under `vendor/`.
- Keep `./sim/regress.sh` green before pushing.

---

## 5. Relationship to the IP track

These two tracks are complementary and can proceed independently:

| | SoC track | IP track |
|---|---|---|
| Question asked | Do the IPs work *together*? | Does *this* IP match its spec? |
| DUT | Whole chip, ROM boots first | One IP, reset and go |
| Environment | Upstream's, reused verbatim | None — the engineer builds it |
| Stimulus | C on the Ibex core + pin-level vseqs | UVM sequences over TL-UL |
| Runtime | ~3 minutes per test | seconds |
| Teaches | Integration, SW/TB sync, chip debug | Agents, scoreboards, RAL, coverage closure |

An engineer who has done neither should start on the **IP track** — the
feedback loop is seconds rather than minutes, and chip-level debug assumes you
already trust the blocks.
