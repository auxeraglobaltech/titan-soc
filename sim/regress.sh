#!/usr/bin/env bash
# sim/regress.sh — titan-soc smoke regression on Xcelium.
#
#   ./sim/regress.sh                 # default smoke set (see SMOKE_TESTS)
#   ./sim/regress.sh t1 t2 ...       # explicit test list
#   COV=1 ./sim/regress.sh           # with coverage collection
#
# Runs each chip-level test serially through dvsim (one xrun sim at a time —
# be polite on the shared server) and prints a PASS/FAIL summary at the end.
# Exit code = number of failing tests. Keep this green before pushing.

set -uo pipefail

REPO_TOP="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default smoke set: fast, entropy-light, known-relevant IPs.
# (full menu: hw/top_earlgrey/dv/chip_smoketests.hjson)
SMOKE_TESTS=(
    chip_sw_gpio_smoketest
    chip_sw_uart_smoketest
    chip_sw_rv_timer_smoketest
    chip_sw_aon_timer_smoketest
    chip_sw_sram_ctrl_smoketest
)

if [[ $# -gt 0 ]]; then TESTS=("$@"); else TESTS=("${SMOKE_TESTS[@]}"); fi

declare -A RESULT
declare -A SECS
fails=0

for t in "${TESTS[@]}"; do
    echo ""
    echo "=== [$t] $(date +%H:%M:%S) ==================================="
    t0=${SECONDS}
    if TEST="${t}" "${REPO_TOP}/sim/run_xcelium.sh" > /tmp/regress_${t}.log 2>&1; then
        # dvsim exit 0 isn't enough — check the run log's verdict
        RUN_LOG="${REPO_TOP}/sim/runs/${t}/run.log"
        if grep -q "TEST PASSED" "${RUN_LOG}" 2>/dev/null; then
            RESULT[$t]=PASS
        else
            RESULT[$t]=FAIL; fails=$((fails+1))
        fi
    else
        RESULT[$t]=FAIL; fails=$((fails+1))
    fi
    SECS[$t]=$(( SECONDS - t0 ))
    echo "    ${RESULT[$t]}  (${SECS[$t]}s)  dvsim log: /tmp/regress_${t}.log"
done

echo ""
echo "==================== REGRESSION SUMMARY ===================="
printf "%-36s %-6s %s\n" "TEST" "RESULT" "TIME"
for t in "${TESTS[@]}"; do
    printf "%-36s %-6s %ss\n" "$t" "${RESULT[$t]}" "${SECS[$t]}"
done
echo "-------------------------------------------------------------"
echo "  ${#TESTS[@]} tests, ${fails} failing"
echo "============================================================="
exit "${fails}"
