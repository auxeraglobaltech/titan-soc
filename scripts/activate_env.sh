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

# srec_cat shim (Python replacement for the srecord host package).
# Lives in the repo (scripts/srec_cat) so a fresh clone works without any
# machine-local install; ~/.local/bin kept as fallback for other host tools.
# IMPORTANT: prepended BEFORE venv activation so the venv's bin/ stays first —
# a stray ~/.local/bin/fusesoc (2.4.6) must not shadow the venv's pinned one.
export PATH="${_TITAN_REPO}/scripts:${HOME}/.local/bin:${PATH}"

# shellcheck disable=SC1091
source "${_TITAN_VENV}/bin/activate"

# Put the OpenTitan repo on PATH/PYTHONPATH for its util scripts (regtool etc.)
export REPO_TOP="${_TITAN_REPO}/vendor/opentitan"

# --- OpenSSL dev headers/libs for DPI C models (crypto.c needs openssl/conf.h)
# This host has no openssl-devel package (no sudo). Reuse: OpenSSL 3 headers
# shipped inside the Cadence IC251 python prefix + dev symlinks to the system
# libcrypto.so.3 prepared in ~/.local/lib64. gcc honors CPATH (-I) and
# LIBRARY_PATH (-L). Guarded: no-op on hosts with a real openssl-devel.
_OSSL_INC="${HOME}/tools/install/IC251/tools.lnx86/atlas/python3.12/prefix/include"
if [[ ! -e /usr/include/openssl/conf.h && -e "${_OSSL_INC}/openssl/conf.h" ]]; then
    export CPATH="${_OSSL_INC}${CPATH:+:${CPATH}}"
    export LIBRARY_PATH="${HOME}/.local/lib64${LIBRARY_PATH:+:${LIBRARY_PATH}}"
    # runtime loader path for the libftdi1 stub (opentitantool outside bazel)
    export LD_LIBRARY_PATH="${HOME}/.local/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fi

# --- Bazel site config: OT's .bazelrc has `try-import .bazelrc-site` and the
# file is upstream-gitignored — the sanctioned per-host escape hatch (NOT a
# vendor edit). openssl-sys's build script gets PKG_CONFIG_PATH through OT's
# own string_flag //third_party/rust:openssl_pkg_config_path (make variable
# OPENSSL_PKG_CONFIG_PATH, default empty) — point it at the pkg-config shims
# (openssl.pc, libudev.pc, ...) prepared in ~/.local/lib/pkgconfig, which
# reference /usr/lib64 runtime libs + the IC251 OpenSSL 3 headers.
# pkg-config shims + dev symlinks + libftdi1 stub: scripts/setup_host_shims.sh
_TITAN_PKGCFG="${HOME}/.local/lib64/pkgconfig"
_TITAN_BAZELRC_SITE="${REPO_TOP}/.bazelrc-site"
if [[ -d "${_TITAN_PKGCFG}" ]]; then
    {
        printf 'build --//third_party/rust:openssl_pkg_config_path=%s\n' "${_TITAN_PKGCFG}"
        printf 'build --action_env=PKG_CONFIG_PATH=%s\n' "${_TITAN_PKGCFG}"
        # srec_cat (repo shim) must be reachable inside Bazel's sandbox:
        # --incompatible_strict_action_env pins PATH to system defaults, so
        # non-hermetic host tools like srec_cat need an explicit PATH override.
        printf 'build --action_env=PATH=%s:%s:/usr/local/bin:/usr/bin:/bin\n' \
            "${_TITAN_REPO}/scripts" "${HOME}/.local/bin"
        # ~/.local/lib64 on every link line: carries the dev symlinks
        # (libssl/libcrypto/libudev) and the STATIC libftdi1.a stub — static
        # so opentitantool has no ftdi NEEDED entry (sandbox actions run
        # `env -`, no LD_LIBRARY_PATH possible). Also forces the relink.
        printf 'build --linkopt=-L%s\n' "${HOME}/.local/lib64"
    } > "${_TITAN_BAZELRC_SITE}.tmp"
    if ! cmp -s "${_TITAN_BAZELRC_SITE}.tmp" "${_TITAN_BAZELRC_SITE}" 2>/dev/null; then
        mv "${_TITAN_BAZELRC_SITE}.tmp" "${_TITAN_BAZELRC_SITE}"
        echo "  (generated ${_TITAN_BAZELRC_SITE})"
    else
        rm -f "${_TITAN_BAZELRC_SITE}.tmp"
    fi
fi

echo "titan-soc environment active:"
echo "  python : $(python --version 2>&1)  ($(command -v python))"
echo "  dvsim  : $(command -v dvsim || echo 'not found')"
echo "  fusesoc: $(fusesoc --version 2>&1 || echo 'not found')"
echo "  REPO_TOP=${REPO_TOP}"
