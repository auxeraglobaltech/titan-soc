# Testplan — Tier 3: Full-chip System Scenarios

Whole-chip behaviors: power states, resets mid-traffic, boot-flow variants,
and long-running stress. These sims are expensive (many are hours on
Xcelium) — they run on demand or nightly, never in the smoke set.

Format per `testplan/README.md`: feature / test file(s) / pass criteria /
coverage goal.

---

## SYS-1: Deep sleep entry/exit via pwrmgr

| Field | Value |
|-------|-------|
| Feature | SW requests deep sleep → AON timer wakeup → warm boot resumes SW |
| Test(s) | upstream `chip_sw_pwrmgr_smoketest` (candidate — not yet run here) |
| Pass criteria | retention SRAM state survives; SW detects warm-boot reason |
| Coverage goal | ≥ 1 sleep/wake cycle; wakeup-reason CSR covered |
| Status | 🔲 candidate — needs a timing/entropy feasibility check on Xcelium |

## SYS-2: Watchdog bite → chip reset → reboot

| Field | Value |
|-------|-------|
| Feature | AON watchdog bite triggers rstmgr reset; chip reboots into TEST ROM |
| Test(s) | trainee-advanced or upstream reuse (to select) |
| Pass criteria | reset reason CSR shows watchdog; second boot reaches `InTest` |
| Coverage goal | watchdog reset path in rstmgr covered |
| Status | 🔲 planned |

## SYS-3: Multi-IP concurrent traffic soak

| Field | Value |
|-------|-------|
| Feature | UART TX stream + GPIO toggling + timer IRQs concurrently for N ms |
| Test(s) | trainee-advanced, composed from Tier-2 pieces |
| Pass criteria | no scoreboard errors, no IRQ starvation, clean completion |
| Coverage goal | cross-coverage of concurrent IRQ sources |
| Status | 🔲 planned — capstone exercise |

---

## Ground rules for this tier

- **Never** add a Tier-3 test to `sim/regress.sh`'s smoke set.
- Coverage runs (`COV=1`) at this tier only for closure work — DBs are large.
- Check `who` before launching; these hog the shared server for hours.
