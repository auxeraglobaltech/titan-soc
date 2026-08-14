# Testplan — Tier 2: Cross-IP Integration

Scenarios where two or more IPs must cooperate: interrupts routed through the
PLIC to the Ibex core, timers waking software, DMA-less data flows between
peripherals and memory. This is the main trainee hunting ground after the
Tier-1 workflow exercises.

Format per `testplan/README.md`: feature / test file(s) / pass criteria /
coverage goal.

---

## INT-1: RV timer interrupt → Ibex

| Field | Value |
|-------|-------|
| Feature | rv_timer compare fires → PLIC → Ibex external IRQ → ISR runs |
| Test(s) | `chip_sw_rv_timer_smoketest` |
| Pass criteria | ISR observes expected tick count; `TEST PASSED CHECKS` |
| Coverage goal | timer IRQ line covered in PLIC functional cov |
| Status | ✅ passing (Phase 4 regression) |

## INT-2: AON timer wakeup/watchdog

| Field | Value |
|-------|-------|
| Feature | Always-on timer counts in AON domain; wakeup + watchdog bark IRQs |
| Test(s) | `chip_sw_aon_timer_smoketest` |
| Pass criteria | both IRQs observed by SW; `TEST PASSED CHECKS` |
| Coverage goal | wakeup and bark paths both exercised |
| Status | ✅ passing (Phase 4 regression) |

## INT-3: GPIO interrupt on input edge  ← first trainee-authored target

| Field | Value |
|-------|-------|
| Feature | DV drives a GPIO input edge → gpio IP raises IRQ → SW ISR handles it |
| Test(s) | trainee-authored: `sw/trainee/gpio_irq_test.c` (to write) |
| Pass criteria | ISR fires exactly once per edge, correct pin ID read from `INTR_STATE` |
| Coverage goal | rising + falling edge interrupts on ≥ 4 pins |
| Test entry | `titan_sw_gpio_irq_test` (vseq: `titan_gpio_irq_vseq`) |
| Status | ✅ **passing (2026-08-14)** — 1/1, 171s, `8 edges, 8 interrupts` |

Notes: uses pins 0–3, both edges (8 interrupts total). SW and TB synchronize
with a three-step handshake (SW drives high → releases → TB drives **all** 32
pins low → SW spins 50µs → SW arms) so that arming cannot race the first edge.

Measured margins on the passing run: TB drove low @3245.5µs, SW armed
@3296.4µs (50µs spin), first edge @3345.5µs — a 49µs cushion.
`ARM_DELAY_CLKS = 10000` = 100µs, confirming a 100MHz CPU clock.

Two constraints that are easy to break:
- `NUM_TEST_PINS` (vseq) must match `kNumTestPins` (C) — no compile-time link.
- The TB must drive **all** `NUM_GPIOS` pins, not just the 4 under test, or
  `dif_gpio_read_all()` returns X and trips the TL-UL `dKnown` assertions
  (quirk #14). Cost one debug cycle.

## INT-1a: RV timer interrupt, repeated deadlines

| Field | Value |
|-------|-------|
| Feature | rv_timer re-armed across several deadlines; counter monotonic; one IRQ each |
| Test(s) | trainee-authored: `sw/trainee/rv_timer_irq_test.c` (C-only, no vseq) |
| Test entry | `titan_sw_rv_timer_irq_test` |
| Pass criteria | exactly `kNumDeadlines` (5) interrupts; counter never goes backwards |
| Coverage goal | timer IRQ line exercised across ≥ 5 arm/ack cycles |
| Status | ✅ **passing (2026-08-14)** — 1/1, 168s |

Extends INT-1 past a single shot: catches a stale comparator, an IRQ that
fails to re-assert after acknowledge, or a counter that stops advancing.
The timer IRQ is taken directly by Ibex, so this overrides `ottf_timer_isr`,
not `ottf_external_isr` — it does not route through the PLIC.

## INT-4: UART loopback under interrupt

| Field | Value |
|-------|-------|
| Feature | UART RX watermark IRQ drives SW to drain FIFO while TX streams |
| Test(s) | trainee-authored (to write) |
| Pass criteria | no FIFO overflow, all bytes echoed correctly |
| Coverage goal | watermark levels 1/4/8 covered |
| Status | 🔲 planned |

---

## Backlog (not yet scheduled)

- SPI host → SPI device internal loopback
- I2C host ↔ DV i2c_agent target mode
- Escalation path: alert_handler → pwrmgr reset request (needs entropy — slow)
