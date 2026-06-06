# overlay/

Project-specific overrides and extensions layered on top of `vendor/opentitan`.

**All modifications to OpenTitan DV infrastructure live here.**  
The vendor tree is never edited directly; the build system (Xcelium / fusesoc) picks
up overlay files to shadow or extend vendor sources.

## Planned sub-directories

| Path | Purpose |
|------|---------|
| `overlay/dv/` | UVM agent/env overrides and additions |
| `overlay/rtl/` | RTL patches (rare; prefer upstream PRs) |
| `overlay/fusesoc/` | Additional FuseSoC .core descriptor files |

## Rule

> If you find yourself editing a file under `vendor/`, stop.  
> Copy it (or the relevant piece) into the matching path under `overlay/` instead.
