#!/usr/bin/env bash
# scripts/gen_bazelrc_site.sh — (re)generate vendor/opentitan/.bazelrc-site
#
# Called by activate_env.sh (bash) and activate_env.csh (csh/tcsh).
# OT's .bazelrc `try-import`s this file and upstream gitignores it — the
# sanctioned per-host hook (NOT a vendor edit). See docs/XCELIUM_NOTES.md
# troubleshooting rows 6-9 for why each line exists.
#
# Usage: gen_bazelrc_site.sh <titan-soc repo root>

set -euo pipefail

REPO="${1:?usage: gen_bazelrc_site.sh <repo root>}"
PKGCFG="${HOME}/.local/lib64/pkgconfig"   # from scripts/setup_host_shims.sh
SITE="${REPO}/vendor/opentitan/.bazelrc-site"

[[ -d "${PKGCFG}" ]] || exit 0   # host shims not set up: nothing to generate

TMP="$(mktemp)"
{
    # openssl-sys build script: OT's own string_flag (rules_rust ignores --action_env)
    printf 'build --//third_party/rust:openssl_pkg_config_path=%s\n' "${PKGCFG}"
    printf 'build --action_env=PKG_CONFIG_PATH=%s\n' "${PKGCFG}"
    # srec_cat (repo shim) reachable inside the sandbox (strict_action_env pins PATH)
    printf 'build --action_env=PATH=%s:%s:/usr/local/bin:/usr/bin:/bin\n' \
        "${REPO}/scripts" "${HOME}/.local/bin"
    # dev symlinks (ssl/crypto/udev) + STATIC libftdi1.a stub on every link line
    printf 'build --linkopt=-L%s\n' "${HOME}/.local/lib64"
} > "${TMP}"

if ! cmp -s "${TMP}" "${SITE}" 2>/dev/null; then
    mv "${TMP}" "${SITE}"
    echo "  (generated ${SITE})"
else
    rm -f "${TMP}"
fi
