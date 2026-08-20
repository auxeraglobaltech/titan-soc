#!/usr/bin/env bash
#
# Compile-check several IPs in sequence and print a summary table.
#
#   ./IP/scripts/compile_all.sh                 every IP under IP/
#   ./IP/scripts/compile_all.sh aes kmac otbn   just these
#   ./IP/scripts/compile_all.sh --sim           run the UVM test too, not just elaborate
#
# Runs strictly one at a time -- the simulation server is shared. Each IP's log
# stays at IP/<ip>/sim/runs/compile.log; this only summarises.
set -uo pipefail

IP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MODE=(--build-only)
IPS=()
for a in "$@"; do
  case "$a" in
    --sim) MODE=() ;;
    -*)    echo "unknown option: $a" >&2; exit 2 ;;
    *)     IPS+=("$a") ;;
  esac
done

if [[ ${#IPS[@]} -eq 0 ]]; then
  while IFS= read -r d; do
    IPS+=("$(basename "$d")")
  done < <(find "$IP_ROOT" -mindepth 1 -maxdepth 1 -type d \
             -not -name common -not -name scripts | sort)
fi

command -v xrun >/dev/null || {
  echo "xrun not on PATH -- source scripts/activate_env.sh first" >&2
  exit 1
}

declare -a PASS=() FAIL=()

for ip in "${IPS[@]}"; do
  printf '%-12s ' "$ip"
  if "$IP_ROOT/scripts/compile_check.sh" "$ip" "${MODE[@]}" >/dev/null 2>&1; then
    printf 'PASS'
    PASS+=("$ip")
  else
    printf 'FAIL'
    FAIL+=("$ip")
  fi
  log="$IP_ROOT/$ip/sim/runs/compile.log"
  if [[ -f "$log" ]]; then
    n=$(grep -cE '^(xmvlog|xmelab|xrun): \*[EF]' "$log")
    first=$(grep -E '^(xmvlog|xmelab): \*[EF]' "$log" | head -1 | cut -c1-90)
    printf '  errors=%-4s %s' "$n" "$first"
  fi
  echo
done

echo
echo "passed ${#PASS[@]}/${#IPS[@]}"
if [[ ${#FAIL[@]} -gt 0 ]]; then
  echo "failed: ${FAIL[*]}"
  echo
  echo "For detail:  less IP/<ip>/sim/runs/compile.log"
  echo "Error lines: grep -nE '^(xmvlog|xmelab): \\*[EF]' IP/<ip>/sim/runs/compile.log | head -20"
  exit 1
fi
