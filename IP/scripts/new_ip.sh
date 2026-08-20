#!/usr/bin/env bash
#
# Scaffold a new IP folder from the pinned vendor tree.
#
#   ./IP/scripts/new_ip.sh <ip> [--autogen] [--extra-rtl <path> ...]
#
#   --autogen           source from hw/top_earlgrey/ip_autogen/<ip> instead of
#                       hw/ip/<ip>  (gpio, pwm, pinmux, rv_plic, alert_handler,
#                       clkmgr, pwrmgr, rstmgr, ...)
#   --extra-rtl <path>  an extra RTL file to copy in and list FIRST in files.f,
#                       relative to vendor/opentitan. Use for packages owned by
#                       another IP -- e.g. spi_host needs spi_device_pkg.
#
# Generates everything except two files that must be finished by hand:
#   verification/tb/tb.sv   -- DUT port connections differ per IP
#   README.md               -- the spec summary and testplan hints
# Both are emitted as stubs with TODO markers and the DUT port list extracted
# from the module header.
#
# Does NOT copy the upstream dv/ environment (that is the exercise) or
# data/<ip>_testplan.hjson (that is the answer key).
set -euo pipefail

IP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="$(cd "$IP_ROOT/.." && pwd)"
V="$REPO/vendor/opentitan"

[[ $# -ge 1 ]] || { echo "usage: $0 <ip> [--autogen] [--extra-rtl <path>]..." >&2; exit 2; }

IP="$1"; shift
AUTOGEN=0
AUTO_DEPS=0
EXTRA_RTL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --autogen)   AUTOGEN=1 ;;
    --auto-deps) AUTO_DEPS=1 ;;
    --extra-rtl) EXTRA_RTL+=("$2"); shift ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

if [[ $AUTOGEN -eq 1 ]]; then
  SRC="$V/hw/top_earlgrey/ip_autogen/$IP"
  SRC_REL="hw/top_earlgrey/ip_autogen/$IP"
else
  SRC="$V/hw/ip/$IP"
  SRC_REL="hw/ip/$IP"
fi

[[ -d "$SRC/rtl" ]] || { echo "no RTL at $SRC/rtl -- wrong name, or try --autogen" >&2; exit 1; }

# Resolve externally-owned packages transitively rather than by hand.
if [[ $AUTO_DEPS -eq 1 ]]; then
  while IFS= read -r dep; do
    [[ -n "$dep" ]] && EXTRA_RTL+=("$dep")
  done < <("$IP_ROOT/scripts/resolve_deps.py" "$IP" --src "$SRC_REL/rtl")
fi

DST="$IP_ROOT/$IP"
mkdir -p "$DST"/{docs,rtl,verification/tb,verification/tests,sim/runs}

# ---------------------------------------------------------------- RTL + docs
cp "$SRC"/rtl/*.sv "$DST/rtl/"
[[ -d "$SRC/doc" ]] && cp "$SRC"/doc/* "$DST/docs/" 2>/dev/null || true
[[ -f "$SRC/data/$IP.hjson" ]] && cp "$SRC/data/$IP.hjson" "$DST/docs/"
[[ -f "$SRC/README.md" ]] && cp "$SRC/README.md" "$DST/docs/upstream_README.md"

for e in ${EXTRA_RTL+"${EXTRA_RTL[@]}"}; do
  cp "$V/$e" "$DST/rtl/"
done

# ------------------------------------------------------------------ files.f
# Packages first (Xcelium compiles a filelist in order and a package must
# precede any scope resolution into it); module order does not matter.
{
  echo "// $IP RTL filelist. Packages first, then modules."
  echo "// Source: vendor/opentitan/$SRC_REL/rtl @ 365c167e"
  if [[ ${#EXTRA_RTL[@]} -gt 0 ]]; then
    echo "//"
    echo "// Externally-owned packages this IP needs (copied in, listed first)."
    echo "// These are NOT in common/ on purpose -- common.f carries what every"
    echo "// IP needs, not what any IP might need. See IP/common/README.md."
    for e in "${EXTRA_RTL[@]}"; do echo "//   $(basename "$e")  <- $e"; done
  fi
  echo
  echo "+incdir+\$IP_ROOT/$IP/rtl"
  echo
  for e in ${EXTRA_RTL+"${EXTRA_RTL[@]}"}; do
    echo "\$IP_ROOT/$IP/rtl/$(basename "$e")"
  done
  for f in "$DST"/rtl/*_pkg.sv; do
    b="$(basename "$f")"
    printf '%s\n' "${EXTRA_RTL[@]-}" | grep -q "/$b\$" && continue
    echo "\$IP_ROOT/$IP/rtl/$b"
  done
  for f in "$DST"/rtl/*.sv; do
    b="$(basename "$f")"
    [[ "$b" == *_pkg.sv ]] && continue
    printf '%s\n' "${EXTRA_RTL[@]-}" | grep -q "/$b\$" && continue
    echo "\$IP_ROOT/$IP/rtl/$b"
  done
} > "$DST/rtl/files.f"

# ------------------------------------------------------------- test package
sed -e "s/@IP@/$IP/g" > "$DST/verification/tests/${IP}_test_pkg.sv" <<'EOF'
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// @IP@ -- compile-check test package.
//
// One test, and it checks nothing. Its only job is to prove the UVM phasing
// runs to completion on top of an elaborated @IP@ DUT.
//
// TODO(trainee): this package is where your real test library goes. Expect it
// to grow an env, a cfg object, a virtual sequencer, a RAL model and a
// seq_lib/ directory -- see ../README.md for the suggested order.

package @IP@_test_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class @IP@_base_test extends uvm_test;
    `uvm_component_utils(@IP@_base_test)

    virtual tb_clk_if clk_if;

    function new(string name = "@IP@_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual tb_clk_if)::get(this, "", "clk_if", clk_if)) begin
        `uvm_fatal(get_type_name(), "clk_if not found in config_db")
      end
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      clk_if.wait_for_reset_release();
      `uvm_info(get_type_name(), "reset released", UVM_LOW)

      // Nothing is driven and nothing is checked -- reaching the end without
      // an elaboration or phasing error is the entire pass criterion.
      clk_if.wait_clks(1000);

      `uvm_info(get_type_name(), "compile check complete -- TEST PASSED", UVM_LOW)

      phase.drop_objection(this);
    endtask

  endclass

endpackage
EOF

# ----------------------------------------------------------------- tb.f
cat > "$DST/verification/${IP}_tb.f" <<EOF
// Full compile filelist for the $IP compile-check TB.
// Used by ../sim/run_compile.sh. \$IP_ROOT is exported by that script.

-f \$IP_ROOT/common/common.f
-f \$IP_ROOT/$IP/rtl/files.f

\$IP_ROOT/common/tb/tb_clk_if.sv
\$IP_ROOT/$IP/verification/tests/${IP}_test_pkg.sv
\$IP_ROOT/$IP/verification/tb/tb.sv
EOF

# --------------------------------------------------------- sim/run_compile.sh
sed -e "s/@IP@/$IP/g" > "$DST/sim/run_compile.sh" <<'EOF'
#!/usr/bin/env bash
# Compile check for the @IP@ IP. Thin wrapper around IP/scripts/compile_check.sh.
#
#   ./run_compile.sh                 elaborate + run @IP@_base_test
#   ./run_compile.sh --build-only    elaborate only
#   ./run_compile.sh --print         print the xrun command, run nothing
#   ./run_compile.sh --waves         dump SHM waves
#
# Results land in ./runs/compile.log
exec "$(dirname "${BASH_SOURCE[0]}")/../../scripts/compile_check.sh" @IP@ "$@"
EOF
chmod +x "$DST/sim/run_compile.sh"

# --------------------------------------------------- verification/README.md
sed -e "s|@IP@|$IP|g" -e "s|@DV@|$SRC_REL/dv|g" \
    > "$DST/verification/README.md" <<'EOF'
# @IP@ — verification (trainee brief)

**What is here**: a testbench that elaborates the DUT and runs a UVM test that
checks nothing. **Everything else is yours to build.**

```
tb/tb.sv                  clk/rst, DUT instance, all inputs tied off, run_test()
tests/@IP@_test_pkg.sv    one uvm_test: wait for reset, idle 1000 clks, pass
@IP@_tb.f                 the compile filelist
```

No agent. No driver. No monitor. No sequencer. No scoreboard. No RAL. No
coverage. That is the point — see [`../../README.md`](../../README.md).

---

## Step 0 — prove it compiles before you touch anything

```bash
source scripts/activate_env.sh
cd IP/@IP@/sim
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
2. **RAL.** Generate from `../docs/@IP@.hjson` with
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
- Do not read `vendor/opentitan/@DV@/` until you have attempted the piece
  yourself. It is the full upstream environment — reading it first turns this
  exercise into a transcription task.
EOF

# ------------------------------------------------------------------- tb.sv
# Generated from the module header: every port declared, every input tied to a
# constant. Validated against six hand-written testbenches -- see docs/IP_WORK.md.
"$IP_ROOT/scripts/gen_tb.py" "$IP" --src "$SRC_REL/rtl" > "$DST/verification/tb/tb.sv"

echo "scaffolded IP/$IP from $SRC_REL"
echo "  rtl:   $(ls "$DST"/rtl/*.sv | wc -l) files ($(( ${#EXTRA_RTL[@]} )) external deps)"
echo "  docs:  $(ls "$DST"/docs 2>/dev/null | wc -l) files"
echo "  ports: $(grep -cE '^\s+\.\w+' "$DST/verification/tb/tb.sv") connected"
