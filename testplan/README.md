# testplan/

Test plan documents for titan-soc, organized by verification tier.

## Files

| File | Scope | Entries |
|------|-------|---------|
| `testplan/connectivity.md` | Pin/bus connectivity and reset checks | CONN-1…5 (4 ✅ passing) |
| `testplan/integration.md` | Cross-IP integration scenarios | INT-1…4 (2 ✅ passing) |
| `testplan/system.md` | Full-chip system-level scenarios | SYS-1…3 (planned) |

## Format

Each plan entry should record:
- Feature under test
- Corresponding test file(s) in `tests/` and/or `sw/tests/`
- Pass criteria
- Coverage closure goal

<!-- TODO: adopt OpenTitan's YAML testplan format once vendor submodule is present
     (vendor/opentitan/util/dvsim/testplanner) -->
