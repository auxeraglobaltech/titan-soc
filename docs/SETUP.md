# Setup — Prerequisites and Verified Commands

This document records every prerequisite, version, and command that was verified
working on the titan-soc training server during Phase 2 (2026-06-06) and
Phase 2.5 (Python 3.11 environment, 2026-06-06).

> **IMPORTANT — read first.** All later phases (chip bring-up, dvsim flows,
> regtool/topgen, RAL generation) **must activate the project Python environment
> first**:
>
> ```bash
> source scripts/activate_env.sh
> ```
>
> This selects the isolated **Python 3.11.15** interpreter and the hash-pinned
> OpenTitan package set. The system Python (3.9) does **not** satisfy OpenTitan's
> requirements and is never used. See §1.

---

## Host environment

| Item | Value |
|------|-------|
| OS | RHEL 9 / Linux 5.14 (x86_64) |
| System Python (untouched) | 3.9.25 at `/usr/bin/python3` |
| Project Python (Phase 2.5) | 3.11.15 — isolated, see §1 |
| RISC-V GCC | 16.1.0 |
| GNU Binutils | 2.46 |
| FuseSoC | 2.4.5 (in venv, OT-pinned) |
| dvsim | 1.34.1 (in venv) |
| Bazelisk | v1.24.1 |
| Bazel | 8.0.1 |
| Xcelium | not on PATH at Phase 2 — licensed, installed separately |

---

## Quick setup

```bash
cd /path/to/titan-soc
bash scripts/setup_env.sh        # checks tools, installs fusesoc/bazel, prints C build cmds
source scripts/activate_env.sh   # activates the Python 3.11 venv (Phase 2.5)
```

`setup_env.sh` never invokes `xrun`. `activate_env.sh` only sets up the
Python environment; it runs no simulator.

---

## 1. Python (Phase 2.5 — isolated 3.11 interpreter)

### The problem (discovered in Phase 2)

The system Python is **3.9.25**. OpenTitan's `python-requirements.txt` (at the
pinned commit) pins `click==8.3.1`, which requires Python ≥ 3.10. On Python 3.9
the hash-pinned install fails hard:

```
ERROR: No matching distribution found for click==8.3.1
```

### Why not pyenv / build-from-source

Hard constraints forbid touching the system Python (the OS depends on it), and
there is **no sudo**. A pyenv/source build was ruled out because the required
dev headers are **missing** and cannot be installed:

```
MISSING /usr/include/openssl/ssl.h    -> no `ssl` module -> pip can't reach PyPI
MISSING /usr/include/ffi.h            -> no `ctypes`     -> many wheels fail
MISSING /usr/include/sqlite3.h, bzlib.h
```

A source build would silently produce a crippled interpreter.

### Chosen method — prebuilt standalone interpreter

We use a **`python-build-standalone`** prebuilt interpreter (the same
self-contained CPython builds that `uv`/`rye` use). It bundles its own OpenSSL,
libffi, sqlite, bz2, lzma — no system dev headers, no sudo, fully relocatable.

| Item | Value |
|------|-------|
| Distribution | astral-sh/python-build-standalone, release `20260602` |
| Asset | `cpython-3.11.15+20260602-x86_64-unknown-linux-gnu-install_only.tar.gz` |
| SHA256 | `1702759f4b44d71d307bc876ef913495461790c9fcfa20d1f67270b22170cd09` (verified against release `SHA256SUMS`) |
| Installed at | `~/.local/opt/python-3.11.15-titan/` |
| Bundled OpenSSL | 3.5.6 |

Provisioning (run once; recorded here for reproducibility):

```bash
URL="https://github.com/astral-sh/python-build-standalone/releases/download/20260602/cpython-3.11.15%2B20260602-x86_64-unknown-linux-gnu-install_only.tar.gz"
curl -sSfL -o /tmp/cpython-3.11.15.tar.gz "$URL"
# verify against the release SHA256SUMS before extracting
mkdir -p ~/.local/opt
tar -xzf /tmp/cpython-3.11.15.tar.gz -C ~/.local/opt
mv ~/.local/opt/python ~/.local/opt/python-3.11.15-titan
```

### Project virtual environment

A venv built **on the 3.11 interpreter** (never on system 3.9) lives at
`titan-soc/.venv` (gitignored):

```bash
~/.local/opt/python-3.11.15-titan/bin/python3 -m venv titan-soc/.venv
source titan-soc/.venv/bin/activate
python -m pip install --upgrade pip
```

### Install OpenTitan requirements (hash-pinned, clean)

```bash
source scripts/activate_env.sh   # or: source .venv/bin/activate
pip install --require-hashes -r vendor/opentitan/python-requirements.txt
```

Result: **clean install, no conflicts, no overrides.** All 900+ hashed entries
resolved. Five sdists built local wheels (crcmod, msgpack-python, pyfinite,
siphash, termcolor). Key pinned versions actually installed:

| Package | Version |
|---------|---------|
| click | 8.3.1 |
| dvsim | 1.34.1 |
| fusesoc | 2.4.5 |
| pydantic | 2.12.5 |
| hjson | 3.1.0 |
| Mako | 1.3.10 |

Full freeze captured at `docs/phase2.5-pip-freeze.txt`.

> Note: this venv pins **fusesoc 2.4.5** (the OT-pinned version), which supersedes
> the standalone `fusesoc 2.4.6` installed to `~/.local` in Phase 2. Always work
> inside the activated venv.

### Activation (use in EVERY later phase)

```bash
source scripts/activate_env.sh
```

This selects the 3.11 venv, exports `REPO_TOP=vendor/opentitan`, and prints the
active python/dvsim/fusesoc. See `scripts/activate_env.sh`.

### Verification (Phase 2.5 — no simulator run)

```text
$ python --version
Python 3.11.15

$ python -c "import click; print(click.__version__)"
8.3.1

$ python -c "import dvsim; print('ok')"
ok

$ dvsim --help        # usage print only — NO flow, NO xrun
usage: dvsim <cfg-hjson-file> [-h] [options]
dvsim is a command line tool to deploy ASIC tool flows.
...
(exit code 0)
```

At this pinned commit OpenTitan ships **no `util/dvsim.py`** — dvsim is the
pip-installed package (entry point: the `dvsim` console script in the venv).

---

## 2. RISC-V toolchain

**Do NOT install another toolchain — use the pre-installed one.**

| Tool | Path | Version |
|------|------|---------|
| gcc | `/home/user1/riscv/bin/riscv32-unknown-elf-gcc` | GCC 16.1.0 |
| objcopy | `/home/user1/riscv/bin/riscv32-unknown-elf-objcopy` | Binutils 2.46 |
| nm | `/home/user1/riscv/bin/riscv32-unknown-elf-nm` | Binutils 2.46 |
| objdump | `/home/user1/riscv/bin/riscv32-unknown-elf-objdump` | Binutils 2.46 |

Add to PATH if not already:

```bash
export PATH=/home/user1/riscv/bin:$PATH
```

Target ISA flags used for Earl Grey (RV32IMC, soft-float ABI):

```
-march=rv32imc -mabi=ilp32
```

---

## 3. FuseSoC

Installed via pip into `~/.local/bin/`:

```bash
pip3 install --user fusesoc
fusesoc --version   # 2.4.6
```

Ensure `~/.local/bin` is on PATH:

```bash
export PATH=$HOME/.local/bin:$PATH
```

FuseSoC is used in Phase 3+ to elaborate the Earl Grey chip design for Xcelium.

---

## 4. Bazel / Bazelisk

OpenTitan ships `vendor/opentitan/bazelisk.sh`, which downloads bazelisk v1.24.1
and uses it to download and run the project's pinned Bazel version.

**No separate bazel or bazelisk installation needed.**

Verify:

```bash
bash vendor/opentitan/bazelisk.sh version
# Bazelisk version: v1.24.1
# Build label: 8.0.1
```

Bazelisk binary is cached at `vendor/opentitan/.bin/` (gitignored by OpenTitan).
Bazel build cache defaults to `~/.cache/bazel/`.

> Note: `bazelisk` is not available on PyPI for Python 3.9 (no binary wheel).
> Use `vendor/opentitan/bazelisk.sh` directly.

---

## 5. Xcelium

**Only presence is checked by `scripts/setup_env.sh` — never invoked by automation.**

At Phase 2, `xrun` was not on PATH on the training server.
Before running simulations, add the Xcelium `bin/` directory to PATH:

```bash
export PATH=/path/to/cadence/xcelium/tools/xcelium/bin:$PATH
xrun -version   # verify presence — do not run a simulation
```

Simulation commands will be provided in Phase 3 for the human operator.

---

## 6. C toolchain smoke test (Phase 2 verified)

The following was compiled and linked successfully during Phase 2.

### Source file: `sw/tests/hello_phase2.c`

Thin bare-metal C, `tohost` pass/fail convention, no CRT0, no DIFs.

### Linker script: `sw/link/earlgrey_sram_test.ld`

Places `.text` at `0x10000000` (Earl Grey `ram_main` base).
Memory map sourced from:
`vendor/opentitan/hw/top_earlgrey/sw/autogen/top_earlgrey_memory.ld`

| Region | Origin | Length |
|--------|--------|--------|
| `ram_main` | `0x10000000` | 128 KiB (`0x20000`) |
| `rom` | `0x00008000` | 32 KiB (`0x8000`) |
| `eflash` | `0x20000000` | 1 MiB (`0x100000`) |

### Compile

```bash
RISCV=/home/user1/riscv/bin/riscv32-unknown-elf

${RISCV}-gcc \
  -march=rv32imc \
  -mabi=ilp32 \
  -Os \
  -ffreestanding \
  -fno-builtin \
  -Wall \
  -c sw/tests/hello_phase2.c \
  -o hello_phase2.o
```

### Link

```bash
${RISCV}-gcc \
  -march=rv32imc \
  -mabi=ilp32 \
  -ffreestanding \
  -nostdlib \
  -T sw/link/earlgrey_sram_test.ld \
  hello_phase2.o \
  -o hello_phase2.elf
```

Note: linker emits `warning: ... has a LOAD segment with RWX permissions` — expected
for a bare SRAM payload with no MPU-aware linker script. Harmless for simulation.

### Verified ELF layout

```
   text    data     bss     dec
     32       0       4      36     hello_phase2.elf

Symbols:
  10000000 T main
  10000020 B tohost
```

Entry at `0x10000000` = `ram_main` base. `tohost` at `0x10000020`.

### Generate memory images

```bash
# Raw binary (for direct SRAM load or srec_cat)
${RISCV}-objcopy -O binary hello_phase2.elf hello_phase2.bin

# Intel HEX (for $readmemh or Xcelium memory init)
${RISCV}-objcopy -O ihex hello_phase2.elf hello_phase2.hex
```

Both produced successfully at Phase 2.

---

## 7. What Phase 3 needs

- ✅ Python ≥ 3.10 — **resolved in Phase 2.5** (isolated 3.11.15 venv; see §1).
  Always `source scripts/activate_env.sh` first.
- Xcelium on PATH (for elaboration and simulation).
- FuseSoC core registration: `fusesoc library add opentitan vendor/opentitan`.
- xrun elaboration command (to be derived from `chip_sim.core` and OpenTitan DV
  scripts — will be printed for human execution in Phase 3).

---

*Last updated: Phase 2.5 — isolated Python 3.11 environment provisioned; OpenTitan
python-requirements installed clean; dvsim entry point verified.*
