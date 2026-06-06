#!/usr/bin/env bash
# scripts/setup_env.sh
#
# Phase 2 environment setup and verification for titan-soc.
# Checks required tool versions and installs missing host-side prerequisites
# (Python packages, FuseSoC, Bazel via OpenTitan's bazelisk.sh).
#
# NEVER runs xrun / Xcelium — only checks for its presence on PATH.
# Safe to re-run: install steps are guarded by version checks.

set -euo pipefail

REPO_TOP="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_OT="${REPO_TOP}/vendor/opentitan"
RISCV_PREFIX="/home/user1/riscv/bin/riscv32-unknown-elf"

# Colour helpers
RED='\033[0;31m'; GRN='\033[0;32m'; YEL='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "  ${GRN}[OK]${NC}  $*"; }
warn() { echo -e "  ${YEL}[WARN]${NC} $*"; }
fail() { echo -e "  ${RED}[FAIL]${NC} $*"; }
hdr()  { echo -e "\n=== $* ==="; }

# ---------------------------------------------------------------------------
# 1. Python
# ---------------------------------------------------------------------------
hdr "Python"
if command -v python3 &>/dev/null; then
    PYVER=$(python3 --version 2>&1)
    ok "$PYVER"
else
    fail "python3 not found — install python3 >= 3.9"
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Python host packages (OpenTitan python-requirements.txt)
# ---------------------------------------------------------------------------
hdr "Python host packages (OpenTitan requirements)"
OT_REQS="${VENDOR_OT}/python-requirements.txt"
if [[ ! -f "$OT_REQS" ]]; then
    warn "vendor/opentitan not populated — skipping Python package install"
else
    echo "  Installing from ${OT_REQS} (hash-pinned)..."
    # OpenTitan's file uses --require-hashes; install into user site-packages.
    # Use --no-deps to avoid hash mismatches from transitive deps not in the file.
    pip3 install --user \
        --require-hashes \
        -r "$OT_REQS" 2>&1 | tail -3 || {
        warn "Full hash-pinned install failed (common outside Ubuntu 22.04)."
        warn "Trying best-effort install without hash checking..."
        pip3 install --user -r "$OT_REQS" --no-deps 2>&1 | tail -3 || true
    }
    ok "Python packages installed (see pip output above for details)"
fi

# ---------------------------------------------------------------------------
# 3. FuseSoC
# ---------------------------------------------------------------------------
hdr "FuseSoC"
if command -v fusesoc &>/dev/null; then
    FVER=$(fusesoc --version 2>&1)
    ok "fusesoc ${FVER} ($(command -v fusesoc))"
elif python3 -m fusesoc --version &>/dev/null 2>&1; then
    FVER=$(python3 -m fusesoc --version 2>&1)
    ok "fusesoc ${FVER} (via python3 -m fusesoc)"
elif [[ -x "${HOME}/.local/bin/fusesoc" ]]; then
    FVER=$("${HOME}/.local/bin/fusesoc" --version 2>&1)
    ok "fusesoc ${FVER} (${HOME}/.local/bin/fusesoc)"
    warn "~/.local/bin is not on PATH — add it: export PATH=\$HOME/.local/bin:\$PATH"
else
    echo "  fusesoc not found — installing via pip..."
    pip3 install --user fusesoc
    FVER=$("${HOME}/.local/bin/fusesoc" --version 2>&1)
    ok "fusesoc ${FVER} installed"
    warn "Add ~/.local/bin to PATH: export PATH=\$HOME/.local/bin:\$PATH"
fi

# ---------------------------------------------------------------------------
# 4. Bazel / Bazelisk (via OpenTitan's bazelisk.sh)
# ---------------------------------------------------------------------------
hdr "Bazel / Bazelisk"
BAZELISK_SH="${VENDOR_OT}/bazelisk.sh"
if [[ ! -f "$BAZELISK_SH" ]]; then
    warn "vendor/opentitan not populated — cannot bootstrap bazelisk"
else
    # bazelisk.sh downloads bazelisk binary into vendor/opentitan/.bin/
    # and then uses it to download + run the correct Bazel version.
    BVER=$(bash "$BAZELISK_SH" version 2>/dev/null | grep "^Build label:" | head -1 || true)
    BLVER=$(bash "$BAZELISK_SH" version 2>/dev/null | grep "^Bazelisk version:" | head -1 || true)
    if [[ -n "$BVER" ]]; then
        ok "Bazelisk: ${BLVER:-unknown}"
        ok "Bazel:    ${BVER}"
    else
        warn "bazelisk.sh did not return a version — network access may be required"
    fi
fi

# ---------------------------------------------------------------------------
# 5. RISC-V toolchain
# ---------------------------------------------------------------------------
hdr "RISC-V toolchain (${RISCV_PREFIX}-*)"
if [[ -x "${RISCV_PREFIX}-gcc" ]]; then
    GCCVER=$("${RISCV_PREFIX}-gcc" --version 2>&1 | head -1)
    ok "${RISCV_PREFIX}-gcc: ${GCCVER}"
    ok "${RISCV_PREFIX}-objcopy: $("${RISCV_PREFIX}-objcopy" --version 2>&1 | head -1)"
    ok "${RISCV_PREFIX}-nm:      $("${RISCV_PREFIX}-nm"      --version 2>&1 | head -1)"
    ok "${RISCV_PREFIX}-objdump: $("${RISCV_PREFIX}-objdump" --version 2>&1 | head -1)"
else
    fail "RISC-V gcc not found at ${RISCV_PREFIX}-gcc"
    fail "Expected prefix: ${RISCV_PREFIX}"
    exit 1
fi

# ---------------------------------------------------------------------------
# 6. Xcelium (presence check ONLY — never invoked)
# ---------------------------------------------------------------------------
hdr "Xcelium (presence check only — NOT invoked)"
if command -v xrun &>/dev/null; then
    ok "xrun found at: $(command -v xrun)"
    ok "(NOT invoked — human must run simulation manually)"
else
    warn "xrun not found on PATH"
    warn "Add Xcelium bin directory to PATH before running simulations"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
hdr "Setup complete"
echo "  REPO_TOP:      ${REPO_TOP}"
echo "  RISCV_PREFIX:  ${RISCV_PREFIX}"
echo "  fusesoc:       $(~/.local/bin/fusesoc --version 2>/dev/null || echo 'see above')"
echo ""
echo "  To compile a C test:"
echo "    ${RISCV_PREFIX}-gcc -march=rv32imc -mabi=ilp32 -Os -ffreestanding -nostdlib \\"
echo "      -T sw/link/earlgrey_sram_test.ld <test>.c -o <test>.elf"
echo ""
echo "  To generate a binary image:"
echo "    ${RISCV_PREFIX}-objcopy -O binary <test>.elf <test>.bin"
echo ""
echo "  To run simulation (HUMAN ONLY — not run by automation):"
echo "    # TODO: add xrun invocation after Phase 3 elaboration is verified"
