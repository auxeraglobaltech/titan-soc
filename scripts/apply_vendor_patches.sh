#!/usr/bin/env bash
# scripts/apply_vendor_patches.sh — apply titan-soc's local patches to vendor/.
#
# WHY THIS EXISTS
# ---------------
# vendor/opentitan is a git SUBMODULE. Edits inside it are never stored in the
# titan-soc repo — `git status` shows only a dirty-submodule marker
# (` m vendor/opentitan`). So a fresh clone, a `git clean`, or a submodule bump
# arrives with the patches MISSING, and the resulting failure is baffling:
#
#     xmvlog: *E,SVNOTY ... class titan_hello_vseq extends chip_sw_base_vseq;
#
# This script makes the working tree self-healing: it is called automatically
# by sim/run_xcelium.sh, so `git clone && source activate && ./sim/run_xcelium.sh`
# just works. It is idempotent — safe to run any number of times.
#
# Patches live in overlay/patches/ (see the README there).

set -euo pipefail

REPO_TOP="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OT="${REPO_TOP}/vendor/opentitan"
PATCH_DIR="${REPO_TOP}/overlay/patches"

if [[ ! -d "${OT}/.git" && ! -f "${OT}/.git" ]]; then
    echo "ERROR: vendor/opentitan is not checked out. Run:" >&2
    echo "  git submodule update --init --recursive" >&2
    exit 1
fi

shopt -s nullglob
patches=("${PATCH_DIR}"/*.patch)
shopt -u nullglob

if [[ ${#patches[@]} -eq 0 ]]; then
    echo "vendor patches: none to apply"
    exit 0
fi

applied=0
already=0
for p in "${patches[@]}"; do
    name="$(basename "${p}")"

    # Already applied? A reverse dry-run succeeding means the change is
    # present in the working tree.
    if git -C "${OT}" apply --check --reverse "${p}" >/dev/null 2>&1; then
        already=$((already+1))
        continue
    fi

    # Not applied — does it apply cleanly?
    if ! git -C "${OT}" apply --check "${p}" >/dev/null 2>&1; then
        echo "ERROR: ${name} does not apply cleanly to vendor/opentitan." >&2
        echo "       The vendor tree probably moved under it (submodule bump)." >&2
        echo "       Re-create it: see overlay/patches/README.md" >&2
        exit 1
    fi

    git -C "${OT}" apply "${p}"
    echo "vendor patches: applied ${name}"
    applied=$((applied+1))
done

echo "vendor patches: ${applied} applied, ${already} already present"
