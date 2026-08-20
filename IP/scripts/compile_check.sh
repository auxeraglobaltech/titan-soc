#!/usr/bin/env bash
#
# Shared xrun driver for the IP compile-check testbenches.
#
#   ./IP/scripts/compile_check.sh <ip> [options]
#
# Options:
#   --print         print the xrun command and exit, do not run anything
#   --build-only    elaborate only, do not simulate
#   --waves         dump SHM waves into the run directory
#   --test <name>   UVM test to run (default: <ip>_base_test)
#
# Everything lands in IP/<ip>/sim/runs/. The log is compile.log.
#
# NOTE: this project's hard rule is that automation never launches a
# simulation -- an operator runs it. Use --print to get the command to paste.
set -euo pipefail

IP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export IP_ROOT

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <ip> [--print] [--build-only] [--waves] [--test <name>]" >&2
  exit 2
fi

IP="$1"; shift
PRINT_ONLY=0
BUILD_ONLY=0
WAVES=0
TEST=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --print)      PRINT_ONLY=1 ;;
    --build-only) BUILD_ONLY=1 ;;
    --waves)      WAVES=1 ;;
    --test)       TEST="$2"; shift ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

TEST="${TEST:-${IP}_base_test}"

SRC_F="$IP_ROOT/$IP/verification/${IP}_tb.f"
RUN_DIR="$IP_ROOT/$IP/sim/runs"

if [[ ! -f "$SRC_F" ]]; then
  echo "no such IP filelist: $SRC_F" >&2
  echo "known IPs: $(cd "$IP_ROOT" && ls -d */ | grep -v -E '^(common|scripts)/' | tr -d / | tr '\n' ' ')" >&2
  exit 1
fi

mkdir -p "$RUN_DIR"

# ---------------------------------------------------------------------------
# Flatten the filelist: follow nested -f, and expand $IP_ROOT ourselves rather
# than depending on xrun's handling of environment variables inside -f files.
# ---------------------------------------------------------------------------
FLAT_F="$RUN_DIR/compile.f"

flatten() {
  local f="$1"
  while IFS= read -r line; do
    line="${line%%//*}"                       # strip // comments
    line="$(echo "$line" | sed 's/[[:space:]]*$//;s/^[[:space:]]*//')"
    [[ -z "$line" ]] && continue
    if [[ "$line" == -f\ * ]]; then
      local nested="${line#-f }"
      nested="${nested//\$IP_ROOT/$IP_ROOT}"
      flatten "$nested"
    else
      echo "${line//\$IP_ROOT/$IP_ROOT}"
    fi
  done < "$f"
}

flatten "$SRC_F" > "$FLAT_F"

NUM_SRC=$(grep -c '\.sv$' "$FLAT_F" || true)

XRUN_ARGS=(
  -64bit
  -sv
  -uvm -uvmhome CDNS-1.2
  -timescale 1ns/1ps
  -access +rwc
  -xmlibdirname "$RUN_DIR/xcelium.d"
  -l "$RUN_DIR/compile.log"
  -f "$FLAT_F"
  -top tb
)

[[ $BUILD_ONLY -eq 1 ]] && XRUN_ARGS+=(-elaborate)
[[ $BUILD_ONLY -eq 0 ]] && XRUN_ARGS+=(+UVM_TESTNAME="$TEST")

if [[ $WAVES -eq 1 ]]; then
  cat > "$RUN_DIR/probe.tcl" <<EOF
database -open -shm -into $RUN_DIR/waves.shm waves
probe -create -database waves tb -depth all -all -memories
run
exit
EOF
  XRUN_ARGS+=(-input "$RUN_DIR/probe.tcl")
fi

echo "IP          : $IP"
echo "test        : $TEST"
echo "filelist    : $FLAT_F  ($NUM_SRC source files)"
echo "run dir     : $RUN_DIR"
echo
echo "xrun ${XRUN_ARGS[*]}"
echo

if [[ $PRINT_ONLY -eq 1 ]]; then
  echo "(--print given; not launching)"
  exit 0
fi

command -v xrun >/dev/null || {
  echo "xrun not on PATH -- source scripts/activate_env.sh first" >&2
  exit 1
}

# Only ever one simulation at a time on the shared server.
exec xrun "${XRUN_ARGS[@]}"
