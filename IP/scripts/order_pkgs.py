#!/usr/bin/env python3
"""Rewrite an IP's rtl/files.f with its packages in true dependency order.

    ./IP/scripts/order_pkgs.py <ip> [--check]

Xcelium compiles a filelist in order, so a package must appear before anything
that scope-resolves into it. Two orderings were wrong before this existed:

  * alphabetical put `aes_pkg.sv` before `aes_reg_pkg.sv`, but aes_pkg
    references aes_reg_pkg -- so 6 IPs failed with NOPBIND;
  * `resolve_deps.py` emitted externally-owned packages in reverse discovery
    order, which only approximates a topological sort -- so otbn, flash_ctrl
    and kmac failed with SVNOTY inside a package.

This does a real topological sort over every package file in the IP's rtl/
directory (its own and the externally-owned ones copied alongside), using the
actual `<pkg>::` and `import <pkg>::` references. Packages provided by
IP/common/ are ignored as edges -- they are already compiled by common.f.

--check exits 1 without writing if the file would change.
"""
import re
import sys
from pathlib import Path

IP_ROOT = Path(__file__).resolve().parent.parent

PKG_DECL = re.compile(r"^\s*package\s+([A-Za-z_]\w*)\s*;", re.M)
REF = re.compile(r"\b([A-Za-z_]\w*)\s*::")


def strip(txt):
    txt = re.sub(r"//[^\n]*", "", txt)
    return re.sub(r"/\*.*?\*/", "", txt, flags=re.S)


def main():
    ip = sys.argv[1]
    check = "--check" in sys.argv
    rtl = IP_ROOT / ip / "rtl"
    files_f = rtl / "files.f"
    old = files_f.read_text()

    srcs = sorted(rtl.glob("*.sv"))

    # package name -> defining file, for packages living in this IP's rtl/
    defines = {}
    for f in srcs:
        for m in PKG_DECL.finditer(strip(f.read_text(errors="ignore"))):
            defines[m.group(1)] = f

    pkg_files = sorted(set(defines.values()))
    owner = {f: {n for n, g in defines.items() if g == f} for f in pkg_files}

    # edges: file -> files it must come after
    needs = {}
    for f in pkg_files:
        txt = strip(f.read_text(errors="ignore"))
        refs = set(REF.findall(txt)) - owner[f]
        needs[f] = {defines[r] for r in refs if r in defines and defines[r] is not f}

    # Kahn, tie-broken by filename so the output is deterministic.
    ordered, remaining = [], dict(needs)
    while remaining:
        ready = sorted(f for f, dep in remaining.items()
                       if not (dep & set(remaining)))
        if not ready:
            cyc = " ".join(sorted(f.name for f in remaining))
            print(f"CYCLE among packages: {cyc}", file=sys.stderr)
            # Emit them anyway, alphabetically -- a cycle is legal in SV only
            # if the references are to types resolved late; let the tool judge.
            ready = sorted(remaining)
        for f in ready:
            ordered.append(f)
            del remaining[f]

    modules = [f for f in srcs if f not in set(pkg_files)]

    header = []
    for line in old.splitlines():
        if line.startswith("$IP_ROOT") or line.startswith("+incdir"):
            break
        header.append(line)

    out = header[:]
    out.append(f"+incdir+$IP_ROOT/{ip}/rtl")
    out.append("")
    out.append("// Packages, topologically sorted by their actual cross-references.")
    out.append("// Regenerate with IP/scripts/order_pkgs.py -- do not hand-sort.")
    for f in ordered:
        out.append(f"$IP_ROOT/{ip}/rtl/{f.name}")
    out.append("")
    out.append("// Modules. Order does not matter in SystemVerilog.")
    for f in modules:
        out.append(f"$IP_ROOT/{ip}/rtl/{f.name}")
    new = "\n".join(out) + "\n"

    if new == old:
        return 0
    if check:
        print(f"{ip}: files.f would change")
        return 1
    files_f.write_text(new)
    print(f"{ip}: reordered {len(ordered)} packages, {len(modules)} modules")
    return 0


if __name__ == "__main__":
    sys.exit(main())
