# IP Work — block-level DV track

> One of two work tracks in this repo. The other is
> **[SOC_WORK.md](SOC_WORK.md)** (chip-level DV on Earl Grey).
> When resuming, read [RESUME_TITAN.md](../RESUME_TITAN.md) first — it says
> which track is active.

**Goal**: give a DV engineer a self-contained block-level playground. Each IP
folder holds the real OpenTitan RTL, the spec, and a skeleton testbench that
does nothing but elaborate cleanly. The engineer reads the spec, writes a
testplan, and builds the UVM environment themselves.

**Non-goal**: shipping a working verification environment. Upstream already has
one for every IP; handing it over would defeat the exercise. Upstream `dv/` is
referenced as a *last-resort* reference, not copied in.

**Status**: ✅ **23 IPs scaffolded, all 23 elaborating clean on Xcelium**
(verified 2026-08-20), covering the whole lowRISC peripheral / system /
security set. The UVM path is proven end to end (gpio ran `TEST PASSED`,
`UVM_ERROR: 0`). Zero environments built anywhere — that is the trainee's job.

---

## 1. Why this track exists

SoC work (the other track) verifies integration: does the GPIO edge reach the
ISR, does the timer wake the core. It deliberately treats each IP as a working
black box.

Block-level DV is the opposite skill and the one most job descriptions actually
ask for: take one IP, read its spec, enumerate its features, build an agent +
scoreboard + RAL around it, and prove the RTL matches the spec. That needs a
bare RTL + spec starting point, which is what `IP/` provides.

---

## 2. Directory layout

```
IP/
├── README.md                    index: IP table, difficulty, how to start
├── common/
│   ├── rtl/                     shared dependencies, copied once
│   │   ├── prim/                165 files — primitives library (14 excluded from common.f)
│   │   ├── prim_generic/         30 files — concrete impls of abstract prims
│   │   ├── tlul/                 29 files — TileLink-UL fabric
│   │   └── top/                 top_pkg.sv, top_racl_pkg.sv
│   ├── common.f                 filelist + incdirs for all of the above
│   ├── tb/tb_clk_if.sv          the one shared interface
│   └── README.md                what these are, and the abstract-prim gotcha
├── scripts/
│   ├── new_ip.sh                scaffold a new IP (--auto-deps chains the rest)
│   ├── resolve_deps.py          transitive package resolution for one IP
│   ├── gen_tb.py                build tb.sv from a module header
│   ├── gen_readme.py            build a factual README from the RTL + docs
│   ├── compile_check.sh         shared xrun driver used by every IP
│   ├── compile_all.sh           run several IPs, print a summary table
│   └── gen_common_f.sh          regenerate common.f after a re-copy
└── <ip>/                        one folder per IP
    ├── README.md                what it does, spec links, vendor paths, status
    ├── docs/                    copied upstream doc/ + register description
    ├── rtl/
    │   ├── *.sv                 copied IP RTL (4–49 files, incl. external pkgs)
    │   └── files.f              this IP's filelist
    ├── verification/
    │   ├── tb/tb.sv             clk/rst, DUT instance, tie-offs, run_test()
    │   ├── tests/<ip>_test_pkg.sv   one bare uvm_test
    │   ├── <ip>_tb.f            full compile filelist
    │   └── README.md            the trainee brief for this IP
    └── sim/
        ├── run_compile.sh       elaborate + run the one test
        └── runs/                logs, waves, xcelium.d (gitignored)
```

---

## 3. Decisions taken (2026-08-20)

| Decision | Choice | Why |
|---|---|---|
| RTL provenance | **Physical copy** into `IP/<ip>/rtl/` | Self-contained; the engineer can inject bugs to prove the TB catches them. Cost: drifts if the submodule is bumped — see [§7](#7-known-risks). |
| First-pass scope | **6 IPs**: `uart`, `i2c`, `spi_host`, `gpio`, `pwm`, `rv_plic` | Spans both vendor trees and three difficulty tiers. Prove the template, then mass-generate the rest — which is what [§6](#6-mass-generation-2026-08-20) did, taking it to 23. |
| Run flow | **Standalone `xrun`** script per IP | No dvsim, no FuseSoC, no Bazel. A trainee can read the whole command in one screen and debug it. |

### Where each IP comes from

The 26 IPs on the lowRISC pages are split across two vendor trees, and the split
is not obvious — this catches people out:

| Source tree | IPs |
|---|---|
| `vendor/opentitan/hw/ip/` | uart, i2c, spi_host, spi_device, usbdev, adc_ctrl, pattgen, sysrst_ctrl, aon_timer, rv_timer, dma, rv_dm, mbx, sram_ctrl, aes, hmac, kmac, csrng, edn, entropy_src, otbn, keymgr, lc_ctrl, rom_ctrl, otp_ctrl, flash_ctrl |
| `vendor/opentitan/hw/top_earlgrey/ip_autogen/` | **gpio, pwm, pinmux, rv_plic**, alert_handler, clkmgr, pwrmgr, rstmgr |

The second group is generated from `hw/ip_templates/` at top build time. Its
RTL is parameterised for Earl Grey specifically (e.g. `gpio` is fixed at 32
pins), which is exactly what we want for a copy.

---

## 4. What "bare minimum verification" means here

`verification/` contains **only** enough to prove the RTL elaborates and a UVM
test can start and end. Concretely, per IP:

- `tb/tb.sv` — clock and reset generation, the DUT instantiated, all inputs
  tied to a safe constant, `initial run_test();`
- `tests/<ip>_base_test.sv` — a `uvm_test` that raises an objection, waits a
  fixed number of clocks, drops it, and reports `TEST PASSED`.
- No agent, no env, no scoreboard, no sequencer, no RAL, no coverage.

That is the deliverable. Everything above it is the exercise.

### The trainee workflow each IP folder implies

1. `./run_compile.sh` — confirm the RTL elaborates clean before touching anything.
2. Read `docs/` and the linked spec; enumerate features.
3. Write `verification/testplan.md` — features, tests, pass criteria, coverage goals.
4. Build the environment: TL-UL agent (reuse `hw/dv/sv/tl_agent`), RAL from the
   `.hjson`, IP-specific agent, scoreboard.
5. Write tests against the testplan; close functional coverage.

---

## 5. Execution plan

| # | Step | Status |
|---|---|---|
| 1 | Create `IP/common/` — copy prim, prim_generic, tlul, top pkgs; write `common.f` | ✅ 212 files |
| 2 | Write `IP/scripts/{compile_check,gen_common_f}.sh` | ✅ |
| 3 | Build **`uart`** (from `hw/ip/`) and **`gpio`** (from `ip_autogen/`) as the two reference IPs | ✅ |
| 4 | **Operator runs both compile checks** — `uart` and `gpio` elaborate clean | ✅ **gate passed 2026-08-20** |
| 5 | Write `new_ip.sh`, generalising from the two proven IPs | ✅ |
| 6 | Scaffold `i2c`, `spi_host`, `pwm`, `rv_plic` | ✅ |
| 7 | Operator runs the four new compile checks | ✅ **all clean 2026-08-20** |
| 8 | Build the generators (`resolve_deps.py`, `gen_tb.py`, `gen_readme.py`) | ✅ |
| 9 | Mass-generate the remaining 17 IPs | ✅ |
| 10 | Operator runs `IP/scripts/compile_all.sh` over all 23 | ✅ **23/23 clean, 2026-08-20** |
| 11 | Curate the 17 generated READMEs (ongoing, can be trainee work) | 🔲 |

Step 4 is a hard gate. Nothing is replicated until elaboration is proven —
otherwise a filelist mistake gets copied twenty times. Two IPs are built rather
than one specifically because they come from *different vendor trees*
(`hw/ip/` vs `ip_autogen/`), which is the difference most likely to break.

`new_ip.sh` is deliberately deferred to step 5, and the three generators to
step 8: a generator written before any IP has compiled would be generalising
from an unproven template. Both were validated against already-passing IPs
before being used at scale — see [§6](#6-mass-generation-2026-08-20).

### Verification status

| Item | State |
|---|---|
| Filelist flattening, `$IP_ROOT` expansion | ✅ works — confirmed by operator run 2026-08-20 |
| Package ordering | ✅ works — no package-binding errors in the ordered head of `common.f` |
| Abstract prim resolution | ✅ works — `prim_generic` binds with no wrapper generation |
| **uart RTL + TB parse** | ✅ **0 errors** — `uart.sv`, `uart_core.sv`, `uart_reg_top.sv`, `uart_rx/tx.sv`, `tb.sv`, `uart_test_pkg.sv`, `tb_clk_if.sv` all clean |
| **gpio RTL + TB parse** | ✅ **0 errors** — same |
| `common.f` contents | ✅ fixed — was over-broad; see run 1 below |
| **uart elaboration** | ✅ **0 errors, snapshot written, 6s** (run 2, 2026-08-20) |
| **gpio elaboration** | ✅ **0 errors, snapshot written, 5s** (run 2, 2026-08-20) |
| Warnings | 3 × `SPDUSD` (unused incdir) — cosmetic, left alone |
| `i2c` / `spi_host` / `pwm` / `rv_plic` elaboration | ✅ **0 errors each, snapshots written, 5–6s** (run 3) |
| **gpio simulation** | ✅ **`TEST PASSED`, `UVM_ERROR: 0`** — reset released @105ns, done @10,105ns (run 3) |

**All six IPs elaborate clean, and the UVM path is proven end to end.** The only
warning any of them produces is `*W,SPDUSD` (declared-but-unused incdir), which
is expected and documented in `IP/README.md`.

The gpio simulation is the proof that matters beyond elaboration: the test
package, the `tb_clk_if` handoff through `uvm_config_db`, objection raise/drop
and `$finish` all work. Timing was exactly as designed — reset released at
105 ns, 1000 clocks at 10 ns, finish at 10,105 ns.

### Run 1 (2026-08-20): 129 parse errors, none of them ours

Both IPs failed identically, in **14 files**, none of which uart or gpio
instantiates. The cause was mine: I copied `prim/` and `tlul/` wholesale on the
assumption that both are generic substrate. They are not — a handful of files
in each belong to a specific IP and scope-resolve into *that IP's* package,
which `common/` does not carry.

| Excluded file(s) | Needs |
|---|---|
| `prim_lc_and_hardened`, `prim_lc_combine`, `prim_lc_dec`, `prim_lc_or_hardened`, `prim_lc_sender`, `prim_lc_sync`, `tlul_lc_gate` | `lc_ctrl_pkg` |
| `prim_edn_req` | `edn_pkg` |
| `prim_flash` | `flash_ctrl_top_specific_pkg` |
| `prim_generic_flash_bank` | `flash_phy_pkg` |
| `tlul_jtag_dtm` | `jtag_pkg` |
| `tlul_adapter_dmi` | `dm` (rv_dm) |
| `tlul_adapter_vh`, `prim_sdc_example` | `ast_pkg` |

**Fix**: an `EXCLUDE` list in `gen_common_f.sh`, with the reason for each entry
recorded inline. `common.f` went 226 → 212 files.

**Consequence for later IPs**: most security IPs (`aes`, `keymgr`, `otbn`,
`csrng`) *do* use `prim_lc_sync`, and `edn`-consuming IPs use `prim_edn_req`.
Those go in the IP's **own** `rtl/files.f`, together with the package they
need — not back into `common.f`. This is the right boundary: `common/` is what
*every* IP needs, not what *any* IP might need.

That the two IPs failed in exactly the same 14 files, and that both DUTs parsed
clean, is the useful signal — it says the substrate is shared correctly and the
per-IP layering works.

---

## 6. Mass generation (2026-08-20)

Hand-writing 17 more IPs was not viable: 17 dependency closures and 17 port
lists, each a chance to introduce a silent error. Three generators were built
instead, and — importantly — **validated against the six hand-written IPs
before being trusted**.

| Script | Does | Validated by |
|---|---|---|
| `resolve_deps.py` | Finds packages an IP references that `common/` lacks, transitively, and locates them in the vendor tree | Reproduced the `spi_host` → `spi_device_pkg` answer derived by hand, in the correct order; correctly reported *nothing* for `gpio`/`uart` |
| `gen_tb.py` | Parses the module header and emits `tb.sv` with every port declared, every input tied to a constant | Port-connection sets compared against all 6 hand-written TBs: **5 exact matches**, `spi_host` differing only by a redundant `#(.NumCS(1))` override |
| `gen_readme.py` | Emits a README of extracted facts (ports, deps, docs, tier) | n/a — output is facts, not analysis |

`new_ip.sh --auto-deps` chains all three.

### Two bugs the validation caught

Both would have been copied 17 times:

1. **Unqualified parameters.** `module uart import uart_reg_pkg::*;` makes
   `NumAlerts` visible *inside* the module only. The generated `tb` declared
   ports of width `[NumAlerts-1:0]` without the import. Fixed by replicating the
   module header's imports into `tb`, plus the IP's `_reg_pkg` when it exists.
2. **Over-eager idle-high heuristic** matched `alert_rx_i` (a differential pair
   with its own default) as if it were a serial RX line. Restricted to `cio_*`.

### Honest limits of the generated output

- **`'0` is not always the right idle level.** Open-drain and serial-idle lines
  want `1`. Rather than guess, `gen_tb.py` ties them low and emits a `TODO`
  naming them. The four curated IPs have this fixed by hand; the 17 do not.
- **No parameter overrides.** Every DUT is instantiated with defaults. Fine for
  a compile check; wrong for IPs whose interesting behaviour is parameterised.
- **READMEs are facts, not analysis.** The 17 generated ones say so at the top
  and point at `uart`/`rv_plic` as examples of a curated page. Padding 17 pages
  with plausible-sounding spec commentary would have been worse than useless —
  a trainee cannot tell invented emphasis from real.

### Getting from 12/23 to 23/23 — four rounds

The first batch run passed 12/23. Every failure was in the tooling, not the
IPs, and each round exposed a genuinely different class of problem:

| Round | Result | What was wrong |
|---|---|---|
| 1 | 12/23 | **Package order was alphabetical, not topological.** `aes_pkg` references `aes_reg_pkg` but sorts first. `resolve_deps.py` also emitted external packages in reverse-discovery order, only an approximation of a topological sort. Fixed by `order_pkgs.py` (real Kahn sort); a semantic no-op on all 12 already passing. |
| 2 | 19/23 | **Excluded modules were never resolved.** Documented in run 1 as "add `prim_lc_sync` to the IP's own filelist", then never implemented — the resolver only handled packages. **9 IPs** needed it. Also: the reference regex required a `_pkg` suffix, so `rv_dm`'s package (literally named `dm`) was invisible. |
| 3 | 20/23 | **Cross-IP *module* dependencies.** `pinmux` instantiates `usbdev_aon_wake`, `rv_dm` instantiates `dm_top` — neither a package nor a prim. Replaced the hardcoded 14-file exception list with general module resolution; the special case now falls out for free. |
| 4 | **23/23** | **Module-local parameters.** `csrng`'s `NumHwApps` is a derived `localparam` and `kmac`'s `NumAppIntf` a plain `parameter`, both in the module's `#(...)` block and in no package — so no import could reach them. `gen_tb.py` now replicates the parameter block. And `rv_dm` had pulled the *Xilinx* `dmi_jtag_tap` (from `dmi_bscane_tap.sv`, instantiating the `BSCANE2` hard macro) because the module index picked alphabetically; it now prefers the file whose name matches the module. |

Two things this sequence is worth remembering for:

- **`csrng` legitimately pulls in the entire AES cipher core** (20 files). It is
  a NIST SP 800-90A CTR_DRBG, and CTR_DRBG uses AES as its block cipher. No one
  reasoning by hand would have predicted that dependency.
- **Each fix was regression-tested against the already-passing IPs before being
  applied.** The general module resolution in round 3 was the risky one — a
  too-loose instantiation regex would pull in junk everywhere — so it was run
  against all 11 passing IPs first and confirmed to resolve to *nothing*.

### Known wrinkle

`gen_tb.py`'s round-4 change also alters the generated output for four IPs that
were already passing (`adc_ctrl`, `flash_ctrl`, `spi_device`, `rv_dm`), by
adding an `import <ip>_pkg::*` line. Those files were **deliberately not
regenerated** — they work, and an unnecessary import risks name ambiguity for
no gain. Consequence: regenerating those four would produce slightly different
(still valid) files from what is checked in.

### Cross-IP dependency load

The boundary rule from run 1 held up under real pressure. Resolved
automatically, no hand intervention:

| IP | External packages pulled in |
|---|---|
| `flash_ctrl` | 14 |
| `otbn` | 10 |
| `aes`, `kmac` | 9 each |
| `csrng`, `pwrmgr` | 6 each |
| `pinmux` | 4 |
| `aon_timer`, `rv_dm` | 3 each |
| `adc_ctrl` | 1 |
| the other 8 | 0 |

`aes` pulling in `lc_ctrl`, `keymgr`, `edn` and `csrng` packages is exactly the
case predicted after run 1 as the one that would exercise the per-IP path.

### Suggested difficulty tiers for the index

| Tier | IPs | Why |
|---|---|---|
| Starter | `gpio`, `pwm`, `pattgen`, `rv_timer` | Register-mapped, few interfaces, no protocol |
| Intermediate | `uart`, `i2c`, `spi_host`, `adc_ctrl`, `aon_timer` | Real serial protocol, FIFOs, interrupts |
| Advanced | `spi_device`, `usbdev`, `dma`, `rv_plic` | Multi-mode, deep state, complex checking |
| Security | `aes`, `hmac`, `kmac`, `csrng`, `otbn`, `keymgr` | Need a reference model; masking/side-channel awareness |

---

## 7. Known risks

- **Copied RTL drifts from the pinned submodule.** If `vendor/opentitan` is ever
  bumped, `IP/` silently goes stale. Mitigation: each `IP/<ip>/README.md`
  records the source path and the pinned commit `365c167e`, and `new_ip.sh`
  can re-copy. Add a `--check` mode that diffs copy vs vendor before trusting a
  result.
- **Abstract prims.** `prim_flop`, `prim_flop_2sync`, `prim_clock_gating` and
  friends are *not* in `hw/ip/prim/rtl/` — FuseSoC resolves them to
  `hw/ip/prim_generic/rtl/`. Copying only `prim/` gives unresolved-module errors
  at elaboration. This is why `common/rtl/prim_generic/` exists.
- **Include paths.** `prim_assert.sv` pulls in `.svh` macro files; `common.f`
  must carry `+incdir+` for `prim/rtl` and `hw/dv/sv/dv_utils` or elaboration
  fails on `` `ASSERT `` macros.
- **`top_racl_pkg` / `top_pkg`** are top-specific, taken from `top_earlgrey`.
  An IP compiled standalone still needs them because `tlul_pkg` references them.
- **Compilation is unverified by me.** Per the project's hard rule, simulations
  are never launched from automation — every `run_compile.sh` is written to be
  read and run by the operator. Treat "elaborates clean" as unproven until
  step 4 above is signed off.

---

## 8. Open questions for later

- Should `IP/` carry a shared TL-UL agent copy so trainees do not have to wire
  into `hw/dv/sv/`? Leaning **no** — reusing upstream `tl_agent` is itself a
  worthwhile lesson.
- Do we want a `solutions/` branch holding a worked example (one fully verified
  IP) for cohort leads? Not scoped.
- Lint/CDC as part of the IP exercise? Upstream ships waivers per IP
  (`lint/*.vlt`, `lint/*.waiver`) which we currently do not copy.
