#!/usr/bin/env bash
# scripts/activate_env.sh
#
# Activate the titan-soc project Python environment.
#
# ALL later phases (chip bring-up, dvsim flows, regtool/topgen, RAL generation)
# MUST source this file first so that the human operator and Claude Code use the
# SAME Python 3.11 interpreter and the SAME hash-pinned OpenTitan package set.
#
# Usage (must be SOURCED, not executed):
#     source scripts/activate_env.sh
#
# This does NOT run any HDL simulator. It only puts the right Python + tools on PATH.

# --- Resolve repo root regardless of where this is sourced from ---------------
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    _TITAN_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
    _TITAN_REPO="$(pwd)"
fi

# --- Isolated interpreter that backs the venv (for documentation/repair) -------
# Provisioned in Phase 2.5 as a prebuilt python-build-standalone interpreter.
# The system Python (/usr/bin/python3, 3.9) is NEVER used or modified.
export TITAN_BASE_PYTHON="${HOME}/.local/opt/python-3.11.15-titan/bin/python3"

# --- Project virtual environment ----------------------------------------------
_TITAN_VENV="${_TITAN_REPO}/.venv"

if [[ ! -f "${_TITAN_VENV}/bin/activate" ]]; then
    echo "ERROR: project venv not found at ${_TITAN_VENV}" >&2
    echo "Recreate it with:" >&2
    echo "  \"${TITAN_BASE_PYTHON}\" -m venv \"${_TITAN_VENV}\"" >&2
    echo "  source \"${_TITAN_VENV}/bin/activate\"" >&2
    echo "  pip install --require-hashes -r vendor/opentitan/python-requirements.txt" >&2
    return 1 2>/dev/null || exit 1
fi

# shellcheck disable=SC1091
source "${_TITAN_VENV}/bin/activate"

# Put the OpenTitan repo on PATH/PYTHONPATH for its util scripts (regtool etc.)
export REPO_TOP="${_TITAN_REPO}/vendor/opentitan"

# srec_cat shim (Python replacement for the srecord host package).
# Lives in the repo (scripts/srec_cat) so a fresh clone works without any
# machine-local install; ~/.local/bin kept as fallback for other host tools.
export PATH="${_TITAN_REPO}/scripts:${HOME}/.local/bin:${PATH}"

echo "titan-soc environment active:"
echo "  python : $(python --version 2>&1)  ($(command -v python))"
echo "  dvsim  : $(command -v dvsim || echo 'not found')"
echo "  fusesoc: $(fusesoc --version 2>&1 || echo 'not found')"
echo "  REPO_TOP=${REPO_TOP}"
