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
EXTRA_RTL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --autogen)   AUTOGEN=1 ;;
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

# ------------------------------------------------------------- tb.sv stub
PORTS="$(sed -n "/^module ${IP}\b/,/^);/p" "$DST/rtl/$IP.sv" | sed 's/^/  \/\/ /')"
cat > "$DST/verification/tb/tb.sv" <<EOF
// $IP -- COMPILE-CHECK TESTBENCH  *** GENERATED STUB, NEEDS HAND-FINISHING ***
//
// TODO: instantiate the DUT and tie off every input. The module header is
// reproduced below for reference. Tie inputs to a CONSTANT, never leave them
// floating -- an X propagating into the register file trips the TL-UL dKnown
// assertions and the failure surfaces long after the real cause.

module tb;

  import uvm_pkg::*;
  import ${IP}_test_pkg::*;
  \`include "uvm_macros.svh"

  logic clk, rst_n;

  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

$PORTS

  // TODO: DUT instance here.

  tb_clk_if clk_if (.clk(clk), .rst_n(rst_n));

  initial begin
    uvm_config_db#(virtual tb_clk_if)::set(null, "*", "clk_if", clk_if);
    run_test();
  end

  initial begin
    #1ms;
    \`uvm_fatal("TB", "timeout -- simulation ran for 1ms with no test completion")
  end

endmodule
EOF

echo "scaffolded IP/$IP from $SRC_REL"
echo "  rtl:   $(ls "$DST"/rtl/*.sv | wc -l) files"
echo "  docs:  $(ls "$DST"/docs 2>/dev/null | wc -l) files"
echo "  TODO:  finish verification/tb/tb.sv and write README.md"
