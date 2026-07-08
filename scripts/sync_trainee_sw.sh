#!/usr/bin/env bash
# scripts/sync_trainee_sw.sh — copy trainee SW tests into the OT bazel tree.
#
# Trainee C tests are AUTHORED and COMMITTED in:   titan-soc/sw/trainee/
# Bazel needs them INSIDE the OT workspace at:     vendor/opentitan/sw/device/tests/titan/
#
# That target directory is a NEW, untracked bazel package (its own BUILD
# file) — no upstream file is ever modified, and `git -C vendor/opentitan
# status` shows only untracked additions. Re-run after every edit.

set -euo pipefail

REPO_TOP="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${REPO_TOP}/sw/trainee"
DST="${REPO_TOP}/vendor/opentitan/sw/device/tests/titan"

[[ -d "${SRC}" ]] || { echo "nothing to sync (${SRC} missing)"; exit 0; }

mkdir -p "${DST}"
rsync -a --delete "${SRC}/" "${DST}/"
echo "synced sw/trainee/ -> vendor/opentitan/sw/device/tests/titan/"
find "${DST}" -type f | sed "s|${DST}/|  |"
