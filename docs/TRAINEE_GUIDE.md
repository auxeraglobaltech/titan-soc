# titan-soc Trainee Guide

Chip-level verification on a real SoC: OpenTitan **Earl Grey** (Ibex RV32
core, TL-UL crossbar, ROM/flash/OTP, full peripheral set) simulated on
Cadence Xcelium with the upstream UVM environment. You extend; you never
edit `vendor/`.

---

## 0. Daily driver commands

```csh
cd titan-soc
source scripts/activate_env.csh      # venv + xrun + bazel site cfg (csh)
./sim/run_xcelium.sh                 # run default test (gpio smoke)
env TEST=<test_name> ./sim/run_xcelium.sh
./sim/run_xcelium.sh --waves shm     # + waveform dump
./sim/waves.sh                       # open newest waves in SimVision
./sim/regress.sh                     # smoke regression — keep it GREEN
less sim/runs/latest/run.log         # newest run's UVM log
```

Never call `simvision` bare — the shared server's PATH serves Incisive 15.2
first and it cannot open 25.03 snapshots (`sim/waves.sh` handles it).

---

## 1. How a chip-level SW test works

```
TEST ROM (in ROM @0x8000)  →  your C test (flash slot A @0x2000_0000)
        │                            │
        └── UVM TB watches the SW test status word @ 0x411f0080
            (sw_test_status_if bound to the sim SRAM)
                 InBootRom → InTest → Passed/Failed  ⇒  UVM PASS/FAIL
```

- Your C program runs under **OTTF** (OpenTitan Test Framework):
  `test_main()` returning `true` ⇒ PASS.
- `LOG_INFO(...)` output appears in
  `sim/runs/<test>/tb...u_sw_logger_if.log`.
- Memory map & status-word derivation: `docs/XCELIUM_NOTES.md`.

---

## 2. Exercise 1 — your first C test (`hello_test`)

Sources live in **`sw/trainee/`** (committed here), and are synced into the
OT bazel workspace as a NEW untracked package (`sw/device/tests/titan/`) —
upstream files are never touched.

```csh
# 1. Look at the template
cat sw/trainee/hello_test.c sw/trainee/BUILD

# 2. Sync into the bazel tree
./scripts/sync_trainee_sw.sh

# 3. Register the test: uncomment the titan_sw_hello_test entry in
#    overlay/titan_sim_cfg.hjson (tests: [...])

# 4. Run it
env TEST=titan_sw_hello_test ./sim/run_xcelium.sh
```

Then work the exercises marked in `hello_test.c`:
- **1a**: drive a peripheral through its DIF (start from
  `vendor/opentitan/sw/device/tests/gpio_smoketest.c` as a worked example)
- **1b**: force a failure and study what FAIL looks like in `run.log`

Adding another test = new `.c` + one `opentitan_test()` in
`sw/trainee/BUILD` + one entry in `overlay/titan_sim_cfg.hjson`.

---

## 3. Exercise 2 — UVM side (read first, write second)

Before writing sequences, learn the environment you're extending:

1. **Trace your test's vseq**: `chip_sw_gpio_smoke_vseq`
   (`vendor/opentitan/hw/top_earlgrey/dv/env/seq_lib/`) — how it syncs with
   the C side via `sw_symbol_backdoor_overwrite` / sw logger.
2. **The base classes**: `chip_sw_base_vseq` (boot, backdoor load),
   `chip_base_test` (cfg knobs, +UVM_TEST_SEQ plumbing).
3. **Exercise**: with waves on, correlate `SwTestStatus*` transitions in
   `run.log` against the `tb.dut.top_earlgrey` hierarchy in SimVision.

Writing a *new* trainee vseq without vendor edits (extra compile unit via
`build_opts` in the overlay cfg) is the advanced track — mechanism drafted,
to be validated as the first cohort reaches it.

---

## 4. Coverage

```csh
env COV=1 TEST=chip_sw_uart_smoketest ./sim/run_xcelium.sh
# report: sim/scratch/HEAD/chip_earlgrey_asic-sim-xcelium/cov_report/
```

Coverage runs are slower and write large DBs — use for closure work, not
every iteration.

---

## 5. Rules of the road

| Rule | Why |
|------|-----|
| Never edit `vendor/opentitan/` tracked files | upstream reuse is the whole point; `git -C vendor/opentitan status` must show only untracked additions |
| Author trainee SW in `sw/trainee/`, then sync | keeps your work committed in THIS repo |
| Keep `./sim/regress.sh` green before pushing | the smoke set is the team's safety net |
| One xrun at a time on the shared server | licenses + RAM are shared (check `who`) |
