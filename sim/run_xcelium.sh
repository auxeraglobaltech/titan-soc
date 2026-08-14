#!/usr/bin/env bash
# sim/run_xcelium.sh
#
# Runs ONE OpenTitan chip-level test on Cadence Xcelium.
#
#   TEST=<name> ./sim/run_xcelium.sh      (default: chip_sw_gpio_smoketest)
#
# Any test from the vendor chip_sim_cfg works, plus the trainee tests
# registered in overlay/titan_sim_cfg.hjson:
#   titan_sw_hello_test                 hello world + first vseq
#   titan_sw_gpio_irq_test              INT-3, GPIO edge -> IRQ -> ISR
#   titan_sw_gpio_out_selfcheck_test    CONN-2a, GPIO output loopback
#   titan_sw_rv_timer_irq_test          INT-1a, repeated timer deadlines
#
# Before invoking dvsim this script re-applies the vendor patches and syncs
# sw/trainee/, so a fresh clone needs no manual setup beyond the env.
#
# >>> THE HUMAN RUNS THIS. Claude Code never executes xrun. <<<
#
# This script orchestrates the OpenTitan DV flow via dvsim (the pip console
# script at this pinned commit), which:
#   1. resolves the file list via FuseSoC,
#   2. builds the SW collateral via Bazel (TEST ROM + gpio test, sim_dv device),
#   3. compiles + elaborates the RTL/TB with Xcelium (xrun),
#   4. runs the simulation with Xcelium (xrun).
#
# Steps 3-4 invoke xrun. Step 2 was already exercised in Phase 3 prep
# (see sim/runs/chip_sw_gpio_smoketest/sw_build.log) to de-risk the SW build.
#
# Prerequisites the HUMAN must satisfy before running:
#   - Xcelium (xrun) on PATH.
#   - Activated project env:  source scripts/activate_env.sh
#
# Usage:
#   source scripts/activate_env.sh
#   ./sim/run_xcelium.sh                # full build + run
#   ./sim/run_xcelium.sh --build-only   # stop after Xcelium elaboration
#   ./sim/run_xcelium.sh --waves shm    # also dump SHM waves (Xcelium native)

set -euo pipefail

# --- Resolve paths ------------------------------------------------------------
REPO_TOP="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OT="${REPO_TOP}/vendor/opentitan"
# Our overlay cfg = vendor chip_sim_cfg imported wholesale + trainee tests
# (titan_sw_*). proj_root stays vendor/opentitan (passed explicitly below).
SIM_CFG="${REPO_TOP}/overlay/titan_sim_cfg.hjson"
# Test selection:  TEST=chip_sw_uart_smoketest ./sim/run_xcelium.sh
TEST_NAME="${TEST:-chip_sw_gpio_smoketest}"

# Coverage:  COV=1 ./sim/run_xcelium.sh  (functional+code cov; slower, big DBs;
# merged report lands under sim/scratch/.../cov_report — open with imc)
COV_ARGS=()
if [[ "${COV:-0}" == "1" ]]; then
    COV_ARGS=(--cov)
fi

# All dvsim output (build + run logs, waves) goes under sim/scratch/ in THIS
# repo — nobody has to dig inside vendor/. sim/runs/latest always points at
# the newest run dir of the last executed test.
SCRATCH="${REPO_TOP}/sim/scratch"

# --- Guard: must be inside the activated venv ---------------------------------
if ! command -v dvsim >/dev/null 2>&1; then
    echo "ERROR: 'dvsim' not found. Activate the project env first:" >&2
    echo "  source scripts/activate_env.sh" >&2
    exit 1
fi

# --- Guard: xrun must be present (we don't run it here, dvsim does) -----------
if ! command -v xrun >/dev/null 2>&1; then
    echo "ERROR: 'xrun' (Xcelium) not found on PATH. Add Xcelium bin/ to PATH." >&2
    exit 1
fi

# --- Make the vendor tree self-healing ----------------------------------------
# vendor/opentitan is a submodule, so titan-soc's local patches are NOT carried
# by a checkout of this repo. Re-apply them (idempotent) so that a fresh clone
# just works instead of failing with a confusing SVNOTY compile error.
"${REPO_TOP}/scripts/apply_vendor_patches.sh"

# --- Sync trainee SW into the OT bazel tree -----------------------------------
# sw/trainee/ is the source of truth; bazel needs the sources inside the OT
# workspace. Doing it here removes a manual step, and kills the "edited the .c,
# forgot to sync, then debugged the previous binary" failure mode.
"${REPO_TOP}/scripts/sync_trainee_sw.sh"

# dvsim must run from the OpenTitan repo root (relative paths, ./bazelisk.sh).
cd "${OT}"

# --- The command --------------------------------------------------------------
# --tool xcelium    : use Cadence Xcelium backend (default cfg tool is vcs).
# --local           : dispatch jobs on this machine (no LSF/cloud scheduler).
# --fixed-seed 1    : deterministic run for first bring-up.
# --scratch-root    : keep all logs/waves in <repo>/sim/scratch (not vendor/).
# "$@"              : pass-through for --build-only / --waves shm / etc.
set -x
rc=0
dvsim "${SIM_CFG}" \
    -i "${TEST_NAME}" \
    --proj-root "${OT}" \
    --tool xcelium \
    --local \
    --fixed-seed 1 \
    --scratch-root "${SCRATCH}" \
    ${COV_ARGS[@]+"${COV_ARGS[@]}"} \
    "$@" || rc=$?
set +x

# --- Convenience pointers ------------------------------------------------------
# dvsim layout: <scratch>/<branch>/chip_earlgrey_asic-sim-xcelium/<n>.<test>/latest
TEST_DIR="$(ls -dt "${SCRATCH}"/*/chip_earlgrey_asic-sim-xcelium/*."${TEST_NAME}" 2>/dev/null | head -1 || true)"
if [[ -n "${TEST_DIR}" && -e "${TEST_DIR}/latest" ]]; then
    mkdir -p "${REPO_TOP}/sim/runs"
    ln -sfn "$(readlink -f "${TEST_DIR}/latest")" "${REPO_TOP}/sim/runs/latest"
    ln -sfn "$(readlink -f "${TEST_DIR}/latest")" "${REPO_TOP}/sim/runs/${TEST_NAME}"
    echo ""
    echo "run dir : sim/runs/latest  ->  $(readlink -f "${TEST_DIR}/latest")"
    echo "main log: sim/runs/latest/run.log"
fi

exit "${rc}"
