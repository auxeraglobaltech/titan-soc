# tests/smoke/ — trainee vseq templates (advanced track)

First trainee-authored UVM sequences. The C-test track (`sw/trainee/`,
Exercise 1) comes first; this vseq track is Exercise 2+.

## Compile mechanism — package re-open technique

All upstream vseqs are `\`include`d inside `chip_env_pkg` (see
`chip_env_pkg.sv` → `chip_vseq_list.sv`). A standalone compile unit
cannot extend package-scoped types, so a simple `build_opts` file append
would fail at elaboration.

**Solution: SystemVerilog package re-open** (IEEE 1800-2017 §26.2).
A second `package chip_env_pkg; ... endpackage` block appends new
identifiers to the already-compiled package namespace, giving the new
classes full visibility of `chip_sw_base_vseq`, `cfg`, `DV_WAIT`, etc.

The file `overlay/titan_vseq_extras.sv` re-opens the package and
`\`include`s each trainee vseq. Two `build_opts` in `titan_sim_cfg.hjson`
wire this in without touching any vendor file:

```
build_opts: [
  "+incdir+{self_dir}/../tests/smoke"
  "{self_dir}/titan_vseq_extras.sv"
]
```

`{self_dir}` resolves to the `overlay/` directory — a dvsim built-in.

**Operator validation required**: run `titan_sw_hello_test` after this
change is committed. If elaboration succeeds and `titan_hello_vseq` is
factory-registered at sim start, the mechanism is confirmed. Record the
result in `docs/XCELIUM_NOTES.md`.

## Files

| File | Pairs with | Exercise |
|------|-----------|----------|
| `titan_hello_vseq.sv` | `sw/trainee/hello_test.c` | 2a: symbol lookup, 2b: backdoor inject |

Naming: `titan_<scenario>_vseq.sv`, mirroring upstream `chip_sw_*_vseq.sv`.
