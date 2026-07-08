# tests/smoke/ — trainee vseq templates (advanced track)

First trainee-authored UVM sequences. The C-test track (`sw/trainee/`,
Exercise 1) comes first; this vseq track is Exercise 2+.

## Compile mechanism — status: DRAFTED, NOT YET VALIDATED

The intent (no vendor edits, same philosophy as the SW overlay):

1. A trainee vseq file here extends `chip_sw_base_vseq` — see
   `titan_hello_vseq.sv`.
2. `overlay/titan_sim_cfg.hjson` adds it as an extra compile unit via
   `build_opts` (an `-f`/`+incdir` addition pointing at this directory),
   compiled into the same `chip_env_pkg` scope after the vendor seq_lib.
3. The test entry sets `uvm_test_seq: titan_hello_vseq` — the upstream
   `chip_base_test` `+UVM_TEST_SEQ` plumbing picks it up by name; no new
   UVM test class is needed.

**Validation TODO (first cohort / operator):** confirm step 2's exact
`build_opts` incantation elaborates on Xcelium — the vseq must see
`chip_env_pkg` internals (macros, `cfg`), which may require a
`` `include``-into-package approach rather than a standalone compile unit.
Record the working recipe here and in `docs/XCELIUM_NOTES.md` when proven.

## Files

| File | Pairs with | Exercise |
|------|-----------|----------|
| `titan_hello_vseq.sv` | `sw/trainee/hello_test.c` | 2a: symbol lookup, 2b: backdoor inject |

Naming: `titan_<scenario>_vseq.sv`, mirroring upstream `chip_sw_*_vseq.sv`.
