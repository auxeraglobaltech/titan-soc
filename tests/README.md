# tests/

Trainee UVM test slots for the OpenTitan Earl Grey SoC.

Trainees write UVM test classes here; the base sequences, agents, and environment
are inherited from `vendor/opentitan/hw/top_earlgrey/dv/` (reused verbatim via
Option B — see `docs/ARCHITECTURE.md`).

## Planned sub-directories

| Path | Purpose |
|------|---------|
| `tests/smoke/` | Bring-up / connectivity tests |
| `tests/functional/` | Per-IP functional test cases |
| `tests/integration/` | Cross-IP integration scenarios |
| `tests/system/` | Full-chip system tests |

## Naming convention

`<ip>_<scenario>_test.sv` — e.g. `uart_loopback_test.sv`, `gpio_output_test.sv`.

Each test class extends the appropriate OpenTitan base test.  
See `testplan/` for the test-plan documents that map tests to features.
