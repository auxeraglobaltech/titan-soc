# Phase 2 Setup — Prerequisites and Verified Commands

This document records every prerequisite, version, and command that was verified
working on the titan-soc training server during Phase 2 (2026-06-06).

---

## Host environment

| Item | Value |
|------|-------|
| OS | RHEL 9 / Linux 5.14 (x86_64) |
| Python | 3.9.25 |
| RISC-V GCC | 16.1.0 |
| GNU Binutils | 2.46 |
| FuseSoC | 2.4.6 |
| Bazelisk | v1.24.1 |
| Bazel | 8.0.1 |
| Xcelium | not on PATH at Phase 2 — licensed, installed separately |

---

## Quick setup

```bash
cd /path/to/titan-soc
bash scripts/setup_env.sh
```

The script checks and installs prerequisites, then prints compile/link commands.
It never invokes `xrun`.

---

## 1. Python

**Required: Python 3.9+ (3.10+ recommended for full OpenTitan python-requirements)**

```bash
python3 --version   # Python 3.9.25 on training server
```

### Python packages — known constraint

OpenTitan's `python-requirements.txt` (at pinned commit) pins `click==8.3.1`,
which requires Python ≥ 3.10. On Python 3.9 the hash-pinned install fails:

```
ERROR: No matching distribution found for click==8.3.1
```

**Workaround for Python 3.9:** Install FuseSoC standalone (see §3) and install
only the Python packages actually needed for our workflow:

```bash
pip3 install --user fusesoc
```

Full OpenTitan tooling (regtool, topgen, dvsim) requires Python ≥ 3.10.
**Recommended:** upgrade the training server to Python 3.10 or 3.11 for Phase 3.

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

- Python ≥ 3.10 on the server (for full OpenTitan python-requirements).
- Xcelium on PATH (for elaboration and simulation).
- FuseSoC core registration: `fusesoc library add opentitan vendor/opentitan`.
- xrun elaboration command (to be derived from `chip_sim.core` and OpenTitan DV
  scripts — will be printed for human execution in Phase 3).

---

*Last updated: Phase 2 — C toolchain proven, prerequisites installed.*
