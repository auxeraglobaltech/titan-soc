#!/usr/bin/env python3
"""Find the package files an IP needs that IP/common/ does not already carry.

    ./IP/scripts/resolve_deps.py <ip> [--src <vendor-relative-rtl-dir>]

Scans the IP's RTL for `<name>_pkg::` scope resolutions, subtracts the packages
already defined by IP/common/ and by the IP itself, then locates each remaining
one in the vendor tree -- transitively, because a package pulled in this way
usually references packages of its own.

Prints the vendor-relative paths in dependency order, one per line, suitable
for feeding to `new_ip.sh --extra-rtl`. Exits 1 if anything cannot be located.

Why this exists: IP/common/ deliberately carries only what *every* IP needs.
Anything IP-specific has to be resolved per IP, and doing that by hand across
20 IPs is error-prone -- see docs/IP_WORK.md.
"""
import re
import sys
from pathlib import Path

IP_ROOT = Path(__file__).resolve().parent.parent
REPO = IP_ROOT.parent
VENDOR = REPO / "vendor" / "opentitan"

PKG_DECL = re.compile(r"^\s*package\s+([A-Za-z_][\w]*)\s*;", re.M)
PKG_REF = re.compile(r"\b([a-z_][\w]*_pkg)\s*::")
# `import foo_pkg::*;` and bare `dm::` style references (rv_dm's package is
# literally named `dm`, not `dm_pkg`), so catch imports separately.
IMPORT_REF = re.compile(r"\bimport\s+([A-Za-z_][\w]*)\s*::")


def decls(files):
    out = {}
    for f in files:
        try:
            txt = f.read_text(errors="ignore")
        except OSError:
            continue
        for m in PKG_DECL.finditer(txt):
            out.setdefault(m.group(1), f)
    return out


def refs(files):
    out = set()
    for f in files:
        txt = f.read_text(errors="ignore")
        # strip line comments so commented-out references do not count
        txt = re.sub(r"//[^\n]*", "", txt)
        out |= set(PKG_REF.findall(txt))
        out |= set(IMPORT_REF.findall(txt))
    return out


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: resolve_deps.py <ip> [--src <rtl-dir>]")
    ip = sys.argv[1]

    src = None
    if "--src" in sys.argv:
        src = VENDOR / sys.argv[sys.argv.index("--src") + 1]
    else:
        for cand in (VENDOR / "hw/ip" / ip / "rtl",
                     VENDOR / "hw/top_earlgrey/ip_autogen" / ip / "rtl"):
            if cand.is_dir():
                src = cand
                break
    if src is None or not src.is_dir():
        sys.exit(f"no RTL dir found for {ip}")

    # Everything already available: common/ plus the IP's own RTL.
    have = set(decls(sorted((IP_ROOT / "common" / "rtl").rglob("*.sv"))))
    ip_files = sorted(src.glob("*.sv"))
    have |= set(decls(ip_files))
    have |= {"uvm_pkg", "std"}

    # Index every package the vendor tree defines, so we can locate the misses.
    index = decls(sorted(VENDOR.glob("hw/**/*.sv")))

    ordered, seen, missing = [], set(have), []
    frontier = sorted(refs(ip_files) - have)

    while frontier:
        nxt = []
        for name in frontier:
            if name in seen:
                continue
            seen.add(name)
            path = index.get(name)
            if path is None:
                missing.append(name)
                continue
            ordered.append(path)
            nxt += sorted(refs([path]) - seen)
        frontier = sorted(set(nxt))

    # A package must be listed before whatever references it; we discovered
    # them the other way round, so reverse.
    ordered.reverse()

    for p in ordered:
        print(p.relative_to(VENDOR))

    if missing:
        print(f"UNRESOLVED: {' '.join(sorted(set(missing)))}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
