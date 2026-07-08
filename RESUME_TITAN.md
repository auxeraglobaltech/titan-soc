# RESUME — titan-soc session handoff

> Read this first when resuming. Then `git log --oneline -10` + the README
> phase table. Written 2026-07-08, just before a server restart.

---

## Where we are

**Phase 4 is COMPLETE and committed** (`da1206a`, `ac88a68` on `main`),
except for **one validation run that needs the human operator** (automation
must never invoke `xrun` — ARCHITECTURE.md §2.2):

```csh
source scripts/activate_env.csh
./scripts/sync_trainee_sw.sh
env TEST=titan_sw_hello_test ./sim/run_xcelium.sh
```

If `grep "TEST PASSED" sim/runs/titan_sw_hello_test/run.log` hits, and the
LOG_INFO string shows in the `u_sw_logger_if.log`, Phase 4 is fully closed —
remove the `*` footnote from the README phase table.

## State of the repo (all committed, working tree clean expected)

| Thing | Status |
|-------|--------|
| Smoke regression `./sim/regress.sh` | 5/5 PASS (gpio, uart, rv_timer, aon_timer, sram_ctrl) |
| `titan_sw_hello_test` | registered LIVE in `overlay/titan_sim_cfg.hjson`; **first run pending (operator)** |
| Testplans | `testplan/{connectivity,integration,system}.md` seeded (CONN-1..5, INT-1..4, SYS-1..3) |
| Trainee vseq template | `tests/smoke/titan_hello_vseq.sv` — **NOT compiled yet**; mechanism drafted in `tests/smoke/README.md` |
| Coverage | `COV=1` plumbed into `run_xcelium.sh`; report under `sim/scratch/HEAD/.../cov_report/` |
| Block diagram | `docs/earlgrey_block_diagram.svg` — generated from real `xbar_{main,peri}.hjson` topology |

## Phase 5 backlog (agreed order)

1. **Close Phase 4**: operator runs `titan_sw_hello_test` (command above);
   update README footnote on PASS.
2. **Validate the vseq compile path** — the big unknown. Prove the
   `build_opts` extra-compile-unit recipe in `overlay/titan_sim_cfg.hjson`
   elaborates `tests/smoke/titan_hello_vseq.sv` on Xcelium. Open question:
   the vseq needs `chip_env_pkg` internals, so a standalone compile unit may
   not work — an `` `include``-into-package trick may be needed. Record the
   working recipe in `tests/smoke/README.md` + `docs/XCELIUM_NOTES.md`.
3. **First trainee-authored test**: INT-3 in `testplan/integration.md` —
   `sw/trainee/gpio_irq_test.c` (GPIO input edge → IRQ → ISR checks
   `INTR_STATE`). This is the Exercise-2 curriculum item.
4. Coverage closure pass on the smoke set (`COV=1 ./sim/regress.sh`),
   merge/report flow in IMC.
5. Candidate feasibility check: `chip_sw_pwrmgr_smoketest` (SYS-1) —
   entropy/timeout tuning likely needed.

## Facts that keep getting re-derived (don't re-derive)

- Bus topology (verified from hjson, NOT from LLM memory):
  `spi_host0/1` + `usbdev` are on **xbar_main**; `rv_timer` is on
  **xbar_peri**. 44 module instances total.
- All 6 registered tests are **C tests** (OTTF, tohost/status-word style);
  zero pure-UVM tests yet — by design (C-first curriculum).
- gpio smoketest is the one smoke test with an active vseq partner
  (`chip_sw_gpio_smoke_vseq` backdoor-injects `kGpioVals`).
- hjson sanity-check trick: parse `overlay/titan_sim_cfg.hjson` with the
  venv's python + hjson module after editing it.
- Rendering SVGs for visual QA: `rsvg-convert` is on the box (no
  ImageMagick/PIL); crop by sed-ing the viewBox into a temp copy.

## Hard rules (never break)

- **Never invoke `xrun`/dvsim sims from automation** — prepare commands,
  print them, the operator runs them. Verdict = `grep "TEST PASSED"
  sim/runs/<test>/run.log`.
- `vendor/opentitan/` is read-only (untracked additions only — the synced
  `sw/device/tests/titan/` package is the one sanctioned addition).
- Project code goes in `overlay/`, `sw/trainee/`, `tests/`; sync SW with
  `./scripts/sync_trainee_sw.sh` after every edit.
- Keep `./sim/regress.sh` green before pushing; one xrun at a time on the
  shared server.

## Session log (2026-07-08, this session)

- Sanity-checked Phase 4: all 5 smoke logs show `TEST PASSED CHECKS`.
- Activated `titan_sw_hello_test` (uncommented in overlay cfg, hjson parse
  verified).
- Wrote the three testplan tiers; created `tests/smoke/` with
  `titan_hello_vseq.sv` + README documenting the unvalidated compile path.
- README: Phase 4 ✅ (footnoted), Phase 5 row added; `.simvision/`
  gitignored. → commit `da1206a`
- Built `docs/earlgrey_block_diagram.svg` from the pinned commit's xbar
  hjson; visually QA'd at 2× per region. → commit `ac88a68`
- Claude memory file exists at
  `~/.claude/projects/-home-user1-Documents-titan-titan-soc/memory/`.
