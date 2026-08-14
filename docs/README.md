# docs/

Project documentation for titan-soc.

## Start here

**[`MASTER.md`](MASTER.md) — the single source of truth.** Status, commands,
SoC description, memory map, DV environment, how to add a test, spec links,
glossary. Everything below is a detail page linked from it.

| File | Contents |
|------|---------|
| [`MASTER.md`](MASTER.md) | **Master reference — read this first** |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Fixed design decisions and their rationale (the "why we chose X" record) |
| [`XCELIUM_NOTES.md`](XCELIUM_NOTES.md) | Bring-up log and 14 numbered host/tool quirks with fixes |
| [`SETUP.md`](SETUP.md) | Host setup detail (shims, toolchain, Python env) |
| [`VENDOR.md`](VENDOR.md) | OpenTitan submodule policy and pinning |
| [`TRAINEE_GUIDE.md`](TRAINEE_GUIDE.md) | Cohort-facing walkthrough |
| [`earlgrey_block_diagram.svg`](earlgrey_block_diagram.svg) | Annotated Earl Grey block diagram (bus topology at the pinned commit; smoke-verified IPs marked ✓) |

## Keeping docs honest

When something goes stale, **fix `MASTER.md` first**, then the detail page. If
two documents disagree, `MASTER.md` wins and the other is a bug.

Related, outside `docs/`:

| File | Contents |
|------|---------|
| [`../README.md`](../README.md) | Quick-start and test table |
| [`../RESUME_TITAN.md`](../RESUME_TITAN.md) | Session handoff — read when resuming work |
| [`../testplan/`](../testplan/) | Test plans by tier (connectivity / integration / system) |
| [`../overlay/patches/README.md`](../overlay/patches/README.md) | Why vendor patches exist and how to re-apply them |
