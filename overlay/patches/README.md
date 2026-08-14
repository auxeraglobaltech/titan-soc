# overlay/patches/

Local patches against `vendor/opentitan/`, kept here because **a titan-soc
commit cannot capture them**. The vendor tree is a git submodule: edits inside
it show up in `git status` only as a dirty-submodule marker (` m vendor/opentitan`),
and their *content* is never stored in this repo. Without these patch files a
`git clean`, a re-clone, or a submodule bump silently loses the change — and
the resulting build failure is confusing (see quirk #12).

## Patches

| File | Target | Purpose |
|------|--------|---------|
| `0001-titan-vseq-hook.patch` | `hw/top_earlgrey/dv/env/seq_lib/chip_vseq_list.sv` | 3-line `` `ifdef TITAN_VSEQ_EXTRAS `` hook that includes `tests/smoke/titan_vseq_list.sv`. The only supported way to add trainee vseqs — see `docs/XCELIUM_NOTES.md` quirk #12. Inert without the define. |

## Check whether it is applied

```csh
git -C vendor/opentitan status --short
```
Expect ` M hw/top_earlgrey/dv/env/seq_lib/chip_vseq_list.sv`. If that line is
missing, the hook is gone and any test with a `uvm_test_seq:` will fail to
compile with `xmvlog: *E,SVNOTY ... chip_sw_base_vseq`.

## Re-apply (after a submodule bump, re-clone, or clean)

```csh
git -C vendor/opentitan apply $PWD/overlay/patches/0001-titan-vseq-hook.patch
```

Verify it landed:
```csh
grep -n TITAN_VSEQ_EXTRAS vendor/opentitan/hw/top_earlgrey/dv/env/seq_lib/chip_vseq_list.sv
```

## Regenerate (if the hook is intentionally changed)

```csh
git -C vendor/opentitan diff -- hw/top_earlgrey/dv/env/seq_lib/chip_vseq_list.sv > overlay/patches/0001-titan-vseq-hook.patch
```

Confirm a saved patch still matches the working tree:
```csh
git -C vendor/opentitan apply --check --reverse $PWD/overlay/patches/0001-titan-vseq-hook.patch
```
