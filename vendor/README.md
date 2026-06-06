# vendor/

This directory holds third-party sources managed as git submodules.

**Read-only. Never edit files under vendor/ directly.**  
All project-specific changes live in `overlay/` and are layered on top at build time.

## Contents (Phase 1+)

- `opentitan/` — OpenTitan Earl Grey SoC, pinned to commit
  `365c167ef632534a1282c780d8b990f46dfbccbf`.  
  Added in Phase 1 via:
  ```
  git submodule add https://github.com/lowRISC/opentitan vendor/opentitan
  git -C vendor/opentitan checkout 365c167ef632534a1282c780d8b990f46dfbccbf
  ```

See `docs/ARCHITECTURE.md` for the full vendor-vs-overlay policy.
