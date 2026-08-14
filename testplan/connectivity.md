# Testplan — Tier 1: Connectivity & Bring-up

Pin/bus connectivity, reset, and boot-path checks. These are the tests that
prove "the chip is alive": clocks tick, reset releases, the core fetches from
ROM, and basic peripherals are reachable over the TL-UL crossbar.

Every entry follows the format from `testplan/README.md`:
feature / test file(s) / pass criteria / coverage goal.

---

## CONN-1: Boot from TEST ROM to SW test

| Field | Value |
|-------|-------|
| Feature | Reset release → TEST ROM executes → jump to flash slot A payload |
| Test(s) | every `chip_sw_*` test exercises this implicitly; canonical: `chip_sw_gpio_smoketest` |
| SW source | `vendor/opentitan/sw/device/tests/gpio_smoketest.c` |
| Pass criteria | `SwTestStatus` transitions `InBootRom → InTest → Passed` in `run.log` |
| Coverage goal | boot-path code coverage in TEST ROM ≥ 80 % (line) |
| Status | ✅ passing (Phase 3) |

## CONN-2: GPIO pad connectivity

| Field | Value |
|-------|-------|
| Feature | GPIO output register → pad ring → DV pin monitor, and input path back |
| Test(s) | `chip_sw_gpio_smoketest` |
| Pass criteria | UVM scoreboard matches every walked-1/walked-0 pattern; `TEST PASSED CHECKS` |
| Coverage goal | all 32 GPIOs toggled both directions (functional cov in upstream env) |
| Status | ✅ passing (Phase 3) |

## CONN-2a: GPIO output loopback, self-checked in SW

| Field | Value |
|-------|-------|
| Feature | Same pad/pinmux loopback as CONN-2, but the check closes in software via `DATA_IN` |
| Test(s) | trainee-authored: `sw/trainee/gpio_out_selfcheck_test.c` (C-only, no vseq) |
| Test entry | `titan_sw_gpio_out_selfcheck_test` |
| Pass criteria | every written pattern reads back identically on `DATA_IN` |
| Coverage goal | walking 1s + walking 0s + all-0/all-1/0xA/0x5 over the testable mask |
| Status | ✅ **passing (2026-08-14)** — 1/1, 168s |

Complements CONN-2: the smoketest observes the pins externally from the TB,
this one closes the loop on-chip. Walking 0s is what catches stuck-high pins,
which walking 1s alone would miss.

## CONN-3: UART TX/RX connectivity

| Field | Value |
|-------|-------|
| Feature | UART0 TX/RX pins ↔ DV uart_agent, baud programming |
| Test(s) | `chip_sw_uart_smoketest` |
| Pass criteria | agent receives exactly the transmitted string; `TEST PASSED CHECKS` |
| Coverage goal | ≥ 1 baud rate exercised per direction (full sweep is Tier 2) |
| Status | ✅ passing (Phase 3) |

## CONN-4: SRAM main/retention reachability

| Field | Value |
|-------|-------|
| Feature | Main and retention SRAM read/write over TL-UL, scrambling enabled |
| Test(s) | `chip_sw_sram_ctrl_smoketest` |
| Pass criteria | pattern write/readback intact in both SRAMs; `TEST PASSED CHECKS` |
| Coverage goal | both SRAM instances touched |
| Status | ✅ passing (Phase 4 regression) |

## CONN-5: Trainee hello world (workflow check)

| Field | Value |
|-------|-------|
| Feature | Trainee SW build/sync/register/run workflow end-to-end |
| Test(s) | `titan_sw_hello_test` (`sw/trainee/hello_test.c`) |
| Pass criteria | `LOG_INFO` string in sw_logger log; `SwTestStatusPassed` |
| Coverage goal | n/a — workflow validation, not feature coverage |
| Status | ✅ passing (2026-08-14) — 1/1, 125s, UVM_ERROR 0. Also validates the trainee **vseq** path: sequencer instance was `...virtual_sequencer.titan_hello_vseq` |

---

## Backlog (not yet scheduled)

- Pinmux/padring connectivity sweep (upstream `chip_padctrl_attributes`-style)
- Straps sampling at reset
- JTAG TAP reachability
