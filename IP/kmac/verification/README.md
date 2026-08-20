# kmac — verification (trainee brief)

**What is here**: a testbench that elaborates the DUT and runs a UVM test that
checks nothing. **Everything else is yours to build.**

```
tb/tb.sv                  clk/rst, DUT instance, all inputs tied off, run_test()
tests/kmac_test_pkg.sv    one uvm_test: wait for reset, idle 1000 clks, pass
kmac_tb.f                 the compile filelist
```

No agent. No driver. No monitor. No sequencer. No scoreboard. No RAL. No
coverage. That is the point — see [`../../README.md`](../../README.md).

---

## Step 0 — prove it compiles before you touch anything

```bash
source scripts/activate_env.sh
cd IP/kmac/sim
./run_compile.sh
grep -E "TEST PASSED|^UVM_(ERROR|FATAL)" runs/compile.log
```

Do this **first**. If elaboration is already broken you want to know before you
have added 2000 lines, so that every later error is provably yours.

> `stat -c "%y" runs/compile.log` before trusting it — the run directory is
> overwritten in place, so a failed build leaves the previous log looking fine.
> The chip track lost a full debug cycle to exactly this.

---

## Step 1 — read the spec and write a testplan

Read `../docs/theory_of_operation.md` and `../docs/registers.md`. Enumerate
every feature, then write `testplan.md` next to this file, using the format in
[`testplan/README.md`](../../../testplan/README.md): feature / test / pass
criteria / coverage goal.

Write it before you write any SystemVerilog. A testplan derived from a TB you
already built will only ever describe what you happened to implement.

---

## Step 2 — build the environment

Suggested order. Each step is independently verifiable — do not write the whole
thing and then start debugging.

1. **TL-UL host agent.** Do not write one. Reuse
   `vendor/opentitan/hw/dv/sv/tl_agent`. Getting it instantiated, connected to
   `tl_i`/`tl_o` through a `tl_if`, and issuing one register read is the single
   biggest step here.
2. **RAL.** Generate from `../docs/kmac.hjson` with
   `vendor/opentitan/util/regtool.py`. Then do a register read/write test —
   that proves agent + RAL + connectivity in one go.
3. **Reset and CSR tests.** Every register reads its documented reset value;
   every RW field holds what you write. Nearly free once the RAL exists, and it
   catches address-decode bugs early.
4. **Pin-level agent.** The IP-specific part: drive and monitor the DUT's own
   interface.
5. **Scoreboard.** Predict outputs from bus activity and compare. This is where
   the actual verification happens.
6. **Interrupts.** The `INTR_STATE` / `INTR_ENABLE` / `INTR_TEST` register
   triple that every comportable IP has, plus each `intr_*_o` line.
7. **Coverage.** Functional covergroups tied to your testplan's coverage goals.

Replace `tb/tb.sv` as you go. Keep the DUT instantiation and clock/reset
generation — those are correct — and swap the tie-offs for interfaces.

---

## Rules

- **One simulation at a time** on the shared server. Check `who` first.
- Tie off every unused DUT input. A floating input propagates X into the
  register file and trips the TL-UL `dKnown` assertions, and the failure
  surfaces long after the real cause.
- Do not edit `../rtl/` — except deliberately, to inject a bug and prove your
  TB catches it. `git diff` shows what you broke; revert afterwards.
- Do not read `vendor/opentitan/hw/ip/kmac/dv/` until you have attempted the piece
  yourself. It is the full upstream environment — reading it first turns this
  exercise into a transcription task.
