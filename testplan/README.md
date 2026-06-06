# testplan/

Test plan documents for titan-soc, organized by verification tier.

## Files (to be populated in Phase 2+)

| File | Scope |
|------|-------|
| `testplan/connectivity.md` | Pin/bus connectivity and reset checks |
| `testplan/integration.md` | Cross-IP integration scenarios |
| `testplan/system.md` | Full-chip system-level scenarios |

## Format

Each plan entry should record:
- Feature under test
- Corresponding test file(s) in `tests/` and/or `sw/tests/`
- Pass criteria
- Coverage closure goal

<!-- TODO: adopt OpenTitan's YAML testplan format once vendor submodule is present
     (vendor/opentitan/util/dvsim/testplanner) -->
