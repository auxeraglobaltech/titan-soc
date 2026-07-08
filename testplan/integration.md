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
| Status | 🔲 planned — Exercise 2 material |

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
