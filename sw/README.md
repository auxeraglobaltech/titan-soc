# sw/

Trainee thin bare-metal C test programs for OpenTitan Earl Grey.

## Design choices

- **Style**: thin bare-metal C with a `tohost` pass/fail convention.  
  No DIF (Device Interface Functions) layer — trainees write direct register
  accesses from the chip memory map.
- **Startup**: handled by OpenTitan's **TEST ROM** (`vendor/opentitan/sw/device/lib/testing/test_framework/`).  
  Trainees do NOT write CRT0 or chip startup code.
- **Toolchain**: `riscv32-unknown-elf-` prefix, installed at  
  `/home/user1/riscv/bin/riscv32-unknown-elf-`
- **Convention**: test passes by writing a non-zero value to the `tohost` symbol;
  failure writes zero (or loops forever).  
  <!-- TODO: confirm exact tohost/fromhost address from OpenTitan memory map -->

## Planned sub-directories

| Path | Purpose |
|------|---------|
| `sw/tests/` | One `.c` file per feature under test |
| `sw/include/` | Shared register-offset headers (auto-generated or hand-written) |

## Example skeleton

```c
// sw/tests/uart_basic.c
#include "regs/uart.h"   // TODO: path once vendor submodule is added

volatile int tohost = 0;

int main(void) {
    // TODO: write UART TX register, poll status
    tohost = 1;  // pass
    return 0;
}
```

See `docs/ARCHITECTURE.md` for the full boot strategy.
