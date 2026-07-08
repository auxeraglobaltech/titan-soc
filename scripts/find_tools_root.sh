#!/usr/bin/env bash
# scripts/find_tools_root.sh — echo the Cadence tools install root
# (the directory containing XCELIUM*/IC251/...), or exit 1 if not found.
#
# The server's tool mount point has moved before (/tools -> ~/tools/install
# -> /man-vol1/tools/install, see docs/XCELIUM_NOTES.md #10/#11), so nothing
# in this repo may hardcode it. Anchor on the resolved path of `xrun`:
# .../tools/install/XCELIUM2503/tools/bin/xrun -> .../tools/install

xrun_path="$(command -v xrun 2>/dev/null || true)"
if [[ -n "${xrun_path}" ]]; then
    root="$(readlink -f "${xrun_path}")"
    root="${root%/XCELIUM*}"
    if [[ -d "${root}" && "${root}" != "$(readlink -f "${xrun_path}")" ]]; then
        echo "${root}"
        exit 0
    fi
fi

# Fallback when xrun isn't on PATH yet: known mount candidates, newest first.
for c in /man-vol1/tools/install "${HOME}/tools/install" /tools/install /tools; do
    if compgen -G "${c}/XCELIUM*" >/dev/null 2>&1 || [[ -d "${c}/IC251" ]]; then
        echo "${c}"
        exit 0
    fi
done

echo "find_tools_root.sh: no Cadence tools root found" >&2
exit 1
