#!/usr/bin/env bash
# sim/waves.sh — open a run's waves.shm in SimVision WITH the design snapshot.
#
#   ./sim/waves.sh                      # newest run (sim/runs/latest)
#   ./sim/waves.sh sim/runs/chip_sw_uart_smoketest
#
# Why this script exists (see also uberddr3's `make waves`):
#   * ~/cshrc puts Incisive 15.2 ($IUSHOME/bin) on PATH BEFORE Xcelium, so a
#     bare `simvision` launches SimVision 15.20 — which cannot open a 25.03
#     snapshot: "ERROR: PPESNAP Unable to start the Post Processing
#     Environment", and without the PPE all signals show as plain `reg`
#     with no input/output direction and no Schematic/Source browser.
#   * Fix: always use the SimVision NEXT TO xrun (same install/version) and
#     pass -cdslib/-snapshot so the PPE loads the elaborated design.

set -euo pipefail

REPO_TOP="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_DIR="${1:-${REPO_TOP}/sim/runs/latest}"
SNAPSHOT="worklib.tb:sv"   # chip DV top (xmelab: "Writing ... worklib.tb:sv")

# --- SimVision matching the Xcelium that built the snapshot --------------------
if ! command -v xrun >/dev/null 2>&1; then
    echo "ERROR: xrun not on PATH — source scripts/activate_env.csh|sh first." >&2
    exit 1
fi
SIMVISION="$(dirname "$(command -v xrun)")/simvision"
[[ -x "${SIMVISION}" ]] || { echo "ERROR: ${SIMVISION} not found." >&2; exit 1; }

# --- Waves DB -------------------------------------------------------------------
WAVES="$(readlink -f "${RUN_DIR}")/waves.shm"
if [[ ! -e "${WAVES}" ]]; then
    echo "ERROR: no waves.shm in ${RUN_DIR}" >&2
    echo "Re-run with waves:  ./sim/run_xcelium.sh --waves shm" >&2
    exit 1
fi

# --- cds.lib of the elaborated snapshot (design DB for the PPE) -----------------
CDS="$(find "${REPO_TOP}"/sim/scratch/*/chip_earlgrey_asic-sim-xcelium/default/xcelium.d \
        -name cds.lib 2>/dev/null | head -1)"
[[ -n "${CDS}" ]] || { echo "ERROR: cds.lib not found — was the design built? (./sim/run_xcelium.sh --build-only)" >&2; exit 1; }

echo "simvision: ${SIMVISION}"
echo "waves    : ${WAVES}"
echo "cdslib   : ${CDS}"
echo "snapshot : ${SNAPSHOT}"

# Detach properly (exec+& is unreliable); keep a log for diagnosis.
LOG="$(dirname "${WAVES}")/simvision.log"
nohup "${SIMVISION}" -64bit -cdslib "${CDS}" -snapshot "${SNAPSHOT}" "${WAVES}" \
    > "${LOG}" 2>&1 &
disown
echo "launched pid $! — log: ${LOG}"
echo "(big snapshot: the main window can take ~15-30s to appear)"
