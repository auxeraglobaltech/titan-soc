# sim/

Cadence Xcelium run scripts and per-run output directories.

## Target simulator

**Cadence Xcelium** (`xrun`).  
Claude Code (or any CI automation) MUST NOT invoke `xrun` directly.  
Scripts here are prepared for a human operator to run.

## Planned contents

| Path | Purpose |
|------|---------|
| `sim/scripts/compile.sh` | One-shot elaboration command (prints `xrun ...` invocation) |
| `sim/scripts/run_test.sh` | Per-test simulation launcher |
| `sim/scripts/regr.sh` | Regression runner (iterates tests/, collects logs) |
| `sim/runs/` | Gitignored; Xcelium drops `xrun.log`, `xcelium.d/`, etc. here |

## .gitignore note

`sim/runs/` is gitignored (`sim/runs/` entry in top-level `.gitignore`).  
Keep a `sim/runs/.gitkeep` so the directory exists after a fresh clone.

<!-- TODO: add xrun elaboration flags once vendor submodule paths are known -->
<!-- TODO: add FuseSoC integration if adopted (Phase 2) -->
