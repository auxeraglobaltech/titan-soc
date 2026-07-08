# tests/

Trainee UVM test slots for the OpenTitan Earl Grey SoC.

Trainees write UVM test classes here; the base sequences, agents, and environment
are inherited from `vendor/opentitan/hw/top_earlgrey/dv/` (reused verbatim via
Option B — see `docs/ARCHITECTURE.md`).

## Sub-directories

| Path | Purpose | Status |
|------|---------|--------|
| `tests/smoke/` | Bring-up vseq templates (Exercise 2) | template + compile-mechanism notes in `tests/smoke/README.md` |
| `tests/functional/` | Per-IP functional test cases | created when first needed |
| `tests/integration/` | Cross-IP integration scenarios | created when first needed |
| `tests/system/` | Full-chip system tests | created when first needed |

## Naming convention

`<ip>_<scenario>_test.sv` — e.g. `uart_loopback_test.sv`, `gpio_output_test.sv`.

Each test class extends the appropriate OpenTitan base test.  
See `testplan/` for the test-plan documents that map tests to features.
