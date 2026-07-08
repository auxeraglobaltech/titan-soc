# RESUME — titan-soc session handoff

> Read this first when resuming. Then `git log --oneline -10` + the README
> phase table. Last updated 2026-07-08.

---

## Where we are

**Phase 4 FULLY CLOSED** — `titan_sw_hello_test` confirmed PASSING by operator.

**Phase 5 in progress** — vseq compile path designed and committed (`9b91d9e`).
**Next operator action required**: validate the package re-open compile.

```csh
source scripts/activate_env.csh
./scripts/sync_trainee_sw.sh
env TEST=titan_sw_hello_test ./sim/run_xcelium.sh
```

Check elaboration log for `titan_hello_vseq` factory registration:
```
grep -i "titan_hello_vseq\|Factory\|ERROR\|Fatal" sim/runs/titan_sw_hello_test/run.log | head -30
```

If elaboration succeeds and vseq is factory-registered → mechanism confirmed,
record quirk in `docs/XCELIUM_NOTES.md`, then proceed to Phase 5 item 3.

If it fails → see "Fallback options" below.

---

## vseq compile mechanism (Phase 5 item 2)

**Technique**: SV package re-open (IEEE 1800-2017 §26.2).

`overlay/titan_vseq_extras.sv` re-opens `chip_env_pkg` and `\`include`s
trainee vseqs. Two `build_opts` in `overlay/titan_sim_cfg.hjson` add it
to every build without touching vendor:

```hjson
build_opts: [
  "+incdir+{self_dir}/../tests/smoke"
  "{self_dir}/titan_vseq_extras.sv"
]
```

`{self_dir}` = dvsim built-in resolving to the `overlay/` directory.

**Fallback options if package re-open fails on Xcelium**:
1. `-define+TITAN_VSEQ_EXTRAS` hook in `chip_vseq_list.sv` (requires one vendor edit, acceptable if re-open is unsupported).
2. Compile as a separate package `titan_env_pkg` that imports `chip_env_pkg`, but then `chip_base_test`'s `+UVM_TEST_SEQ` factory lookup must find the class — may work if both packages are compiled.

---

## Phase 5 backlog (updated order)

1. ✅ **Close Phase 4**: done — hello_test PASSING
2. **Validate vseq compile** (package re-open) — OPERATOR RUN PENDING (command above)
3. **First trainee test**: `sw/trainee/gpio_irq_test.c` (INT-3) — GPIO input edge → IRQ → ISR checks `INTR_STATE`
4. Coverage closure pass (`COV=1 ./sim/regress.sh`), merge in IMC
5. Feasibility check: `chip_sw_pwrmgr_smoketest` (SYS-1)

---

## Facts that keep getting re-derived (don't re-derive)

- Bus topology: `spi_host0/1` + `usbdev` on **xbar_main**; `rv_timer` on **xbar_peri**. 44 module instances total.
- All 6 registered tests are **C tests** (OTTF, tohost/status-word); zero pure-UVM tests yet.
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
