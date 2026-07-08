# scripts/activate_env.csh
#
# csh/tcsh flavor of activate_env.sh — for users whose login shell is csh
# (e.g. the Cadence ~/cshrc workflow). Keep the two in sync; the bash one
# is canonical.
#
# Usage (must be SOURCED from the repo root):
#     cd /home/user1/Documents/titan/titan-soc
#     source scripts/activate_env.csh
#
# NOTE: no `exit` anywhere — exiting a sourced csh script kills the shell.

if (! -e scripts/activate_env.csh) then
    echo "ERROR: source this from the titan-soc repo root:"
    echo "  cd <titan-soc> && source scripts/activate_env.csh"
else
    set _titan_repo = $cwd

    # Isolated interpreter that backs the venv (documentation/repair only)
    setenv TITAN_BASE_PYTHON ${HOME}/.local/opt/python-3.11.15-titan/bin/python3

    # Repo scripts (srec_cat shim) + ~/.local/bin BEFORE venv activation so
    # the venv's pinned fusesoc/dvsim stay first on PATH.
    setenv PATH ${_titan_repo}/scripts:${HOME}/.local/bin:${PATH}

    if (! -e ${_titan_repo}/.venv/bin/activate.csh) then
        echo "ERROR: project venv not found at ${_titan_repo}/.venv"
        echo "See scripts/activate_env.sh header for the recreate recipe."
    else
        source ${_titan_repo}/.venv/bin/activate.csh

        setenv REPO_TOP ${_titan_repo}/vendor/opentitan

        # OpenSSL dev headers/libs for DPI C models + host lib shims
        # (see scripts/setup_host_shims.sh and docs/XCELIUM_NOTES.md rows 5,8,9)
        set _ossl_inc = ${HOME}/tools/install/IC251/tools.lnx86/atlas/python3.12/prefix/include
        if (! -e /usr/include/openssl/conf.h && -e ${_ossl_inc}/openssl/conf.h) then
            setenv CPATH ${_ossl_inc}
            setenv LIBRARY_PATH ${HOME}/.local/lib64
            if ($?LD_LIBRARY_PATH) then
                setenv LD_LIBRARY_PATH ${HOME}/.local/lib64:${LD_LIBRARY_PATH}
            else
                setenv LD_LIBRARY_PATH ${HOME}/.local/lib64
            endif
        endif

        # Bazel site config — same generator as the bash flavor
        ${_titan_repo}/scripts/gen_bazelrc_site.sh ${_titan_repo}

        echo "titan-soc environment active (csh):"
        echo "  python : `python --version`  (`which python`)"
        echo "  dvsim  : `which dvsim`"
        echo "  fusesoc: `fusesoc --version`"
        echo "  REPO_TOP=${REPO_TOP}"
    endif
endif
