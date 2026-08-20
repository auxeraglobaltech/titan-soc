#!/usr/bin/env bash
# Compile check for the rv_plic IP. Thin wrapper around IP/scripts/compile_check.sh.
#
#   ./run_compile.sh                 elaborate + run rv_plic_base_test
#   ./run_compile.sh --build-only    elaborate only
#   ./run_compile.sh --print         print the xrun command, run nothing
#   ./run_compile.sh --waves         dump SHM waves
#
# Results land in ./runs/compile.log
exec "$(dirname "${BASH_SOURCE[0]}")/../../scripts/compile_check.sh" rv_plic "$@"
