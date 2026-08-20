# IP/common — shared dependencies

Every IP in this tree needs the same substrate. Rather than resolve it per IP,
it is copied once here and pulled in by every `<ip>_tb.f` via `-f common.f`.

Copied from OpenTitan **`365c167e`**, the commit pinned at `vendor/opentitan`.

| Directory | Files | From | What it is |
|---|---|---|---|
| `rtl/prim/` | 165 | `hw/ip/prim/rtl` | The primitives library — FIFOs, CDC synchronisers, SECDED, mubi, alert senders, `prim_subreg` (the building block of every register file) |
| `rtl/prim_generic/` | 30 | `hw/ip/prim_generic/rtl` | Concrete implementations of the *abstract* prims. See the gotcha below. |
| `rtl/tlul/` | 29 | `hw/ip/tlul/rtl` | TileLink-UL fabric — `tlul_adapter_reg` is what connects a register file to the bus |
| `rtl/top/` | 2 | `hw/top_earlgrey/rtl` | `top_pkg.sv` and `autogen/top_racl_pkg.sv` — bus widths and RACL policy types |
| `tb/` | 1 | — | `tb_clk_if.sv`, written here, not vendored |

---

## The abstract prim gotcha

`prim_flop`, `prim_flop_2sync`, `prim_buf`, `prim_clock_gating` and friends are
**not** in `hw/ip/prim/rtl/`. They are *abstract*: FuseSoC picks an
implementation per target technology (`prim_generic`, `prim_xilinx`,
`prim_asap7`, …) and binds it.

For a simulation build the answer is always `prim_generic`, and — helpfully —
its files declare the plain module names (`module prim_flop`, not
`prim_generic_flop`), so no wrapper generation is needed. Compiling both
directories together just works.

Copy only `prim/` and you get a pile of unresolved-module errors at
elaboration with no obvious cause. That is why `prim_generic/` is here.

---

## What is NOT in common.f, and why

`rtl/prim/` and `rtl/tlul/` hold the full upstream directories, but `common.f`
**excludes 14 of those files**. They are not generic substrate — each belongs
to a specific IP and scope-resolves into that IP's package:

| Excluded | Needs |
|---|---|
| `prim_lc_*` (6 files), `tlul_lc_gate` | `lc_ctrl_pkg` |
| `prim_edn_req` | `edn_pkg` |
| `prim_flash`, `prim_generic_flash_bank` | flash packages |
| `tlul_jtag_dtm`, `tlul_adapter_dmi` | `jtag_pkg`, `dm` |
| `tlul_adapter_vh`, `prim_sdc_example` | `ast_pkg` |

Including them cost 129 parse errors on the first run. The exclusion list lives
in `scripts/gen_common_f.sh` with the reason for each entry.

**If your IP needs one of these** — most security IPs use `prim_lc_sync`, and
EDN consumers use `prim_edn_req` — add it, plus the package it depends on, to
your IP's own `rtl/files.f`. Do not put it back in `common.f`. The rule is:
`common/` carries what *every* IP needs, not what *any* IP might need.

---

## Package ordering

`common.f` lists packages explicitly, in dependency order, before any module.
Xcelium compiles a filelist in order, and these scope-resolve into each other:

```
tlul_pkg      -> top_pkg, prim_mubi_pkg, prim_secded_pkg
top_racl_pkg  -> top_pkg, prim_util_pkg, tlul_pkg
```

Do not hand-edit or alphabetise `common.f`. Regenerate it:

```bash
./IP/scripts/gen_common_f.sh
```

The generator has the order baked in and fails loudly if a package is missing.

---

## Include paths

`common.f` carries `+incdir+` for `rtl/prim`, `rtl/prim_generic` and `rtl/tlul`.
`prim_assert.sv` pulls in `prim_assert_standard_macros.svh` and friends by
bare filename; without the incdir every `` `ASSERT `` macro fails to expand.

---

## Refreshing after a submodule bump

This is a **copy**, so it does not track `vendor/opentitan`. To refresh:

```bash
V=vendor/opentitan
cp $V/hw/ip/prim/rtl/*.sv $V/hw/ip/prim/rtl/*.svh IP/common/rtl/prim/
cp $V/hw/ip/prim_generic/rtl/*.sv                 IP/common/rtl/prim_generic/
cp $V/hw/ip/tlul/rtl/*.sv                         IP/common/rtl/tlul/
cp $V/hw/top_earlgrey/rtl/top_pkg.sv              IP/common/rtl/top/
cp $V/hw/top_earlgrey/rtl/autogen/top_racl_pkg.sv IP/common/rtl/top/
./IP/scripts/gen_common_f.sh
```

Then re-run every IP's compile check — a new prim can change the package order.

---

## Not here on purpose

- **No DV library.** `hw/dv/sv/` (tl_agent, common_ifs, dv_utils, dv_lib) is
  *not* copied. Trainees reference it directly from `vendor/opentitan`;
  locating and integrating an existing agent is itself part of the exercise.
- **No lint waivers.** Upstream ships `lint/*.vlt` and `lint/*.waiver` per IP.
  Out of scope for now.
