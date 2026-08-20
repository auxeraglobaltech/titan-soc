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
# Any `ident::` scope resolution. Deliberately NOT restricted to a _pkg suffix:
# rv_dm's package is literally named `dm`, and requiring the suffix made its
# dependency invisible. Names that turn out not to be packages (class scopes,
# enum qualifications) simply never match the vendor package index and are
# dropped.
PKG_REF = re.compile(r"\b([A-Za-z_][\w]*)\s*::")
IMPORT_REF = re.compile(r"\bimport\s+([A-Za-z_][\w]*)\s*::")

MOD_DECL = re.compile(r"^\s*module\s+([A-Za-z_]\w*)", re.M)

# Module instantiation, in the two styles OpenTitan RTL uses:
#     foo_mod #(.P(1)) u_x (...)
#     foo_mod u_x (...)
INST_PARAM = re.compile(r"^[ \t]*([a-zA-Z_]\w*)\s*#\s*\(", re.M)
INST_PLAIN = re.compile(r"^[ \t]*([a-zA-Z_]\w*)\s+([a-zA-Z_]\w*)\s*\(", re.M)

# Words that appear in instantiation position but are not module names.
NOT_A_MODULE = {
    "module", "endmodule", "if", "else", "for", "while", "case", "casez",
    "casex", "always", "always_ff", "always_comb", "always_latch", "assign",
    "initial", "final", "function", "task", "return", "begin", "end",
    "generate", "endgenerate", "logic", "wire", "reg", "bit", "byte", "int",
    "integer", "localparam", "parameter", "typedef", "struct", "union",
    "enum", "package", "import", "export", "interface", "modport", "class",
    "virtual", "static", "automatic", "input", "output", "inout", "ref",
    "unique", "priority", "posedge", "negedge", "or", "and", "not",
    "assert", "assume", "cover", "property", "sequence", "disable",
}


def strip(txt):
    """Remove comments, so a name mentioned in prose is not treated as used."""
    txt = re.sub(r"//[^\n]*", "", txt)
    return re.sub(r"/\*.*?\*/", "", txt, flags=re.S)


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

    # --local scans IP/<ip>/rtl, i.e. what will actually be compiled. Prefer it
    # when refreshing an already-scaffolded IP: it accounts for files already
    # copied in, and it cannot pick the wrong vendor tree. (hw/ip/flash_ctrl
    # and hw/top_earlgrey/ip_autogen/flash_ctrl both exist and differ.)
    src = None
    if "--local" in sys.argv:
        src = IP_ROOT / ip / "rtl"
    elif "--src" in sys.argv:
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
    vendor_srcs = sorted(VENDOR.glob("hw/**/*.sv"))
    index = decls(vendor_srcs)

    # Every module the vendor tree defines. Technology-specific prim variants
    # are skipped -- simulation always wants the prim_generic implementation.
    # When two files define the same module, prefer the one whose filename
    # matches the module name -- that is reliably the generic implementation.
    # dmi_jtag_tap is defined both in dmi_jtag_tap.sv (generic) and in
    # dmi_bscane_tap.sv (Xilinx, instantiates the BSCANE2 hard macro). Picking
    # alphabetically got the FPGA one and left BSCANE2 unresolvable.
    mod_index = {}
    for f in vendor_srcs:
        if any(t in str(f) for t in ("/prim_xilinx", "/prim_asap7")):
            continue
        for m in MOD_DECL.finditer(strip(f.read_text(errors="ignore"))):
            name = m.group(1)
            if name not in mod_index or f.stem == name:
                mod_index[name] = f

    # Modules already compiled by common.f. NOTE: this is common.f, not
    # common/rtl/ -- 14 files sit in the directory but are deliberately not
    # compiled (see gen_common_f.sh), so an IP that instantiates one must get
    # its own copy. That case falls out of this general mechanism for free.
    common_have = set()
    for line in (IP_ROOT / "common" / "common.f").read_text().splitlines():
        line = line.strip()
        if line.startswith("$IP_ROOT"):
            p = IP_ROOT / line.replace("$IP_ROOT/", "")
            if p.exists():
                common_have |= set(MOD_DECL.findall(strip(p.read_text(errors="ignore"))))

    def wanted_modules(files, defined):
        """Modules instantiated by these files that nothing has defined yet."""
        out = set()
        for f in files:
            txt = strip(f.read_text(errors="ignore"))
            names = set(INST_PARAM.findall(txt))
            names |= {m[0] for m in INST_PLAIN.findall(txt)}
            for n in names - NOT_A_MODULE - defined:
                if n in mod_index:
                    out.add(n)
        return out

    # Modules defined locally (the IP's own rtl) or already in common.f.
    mods_defined = set(common_have)
    for f in ip_files:
        mods_defined |= set(MOD_DECL.findall(strip(f.read_text(errors="ignore"))))

    ordered, seen = [], set(have)
    mods, mods_seen = [], set()
    frontier = sorted(refs(ip_files) - have)
    mod_frontier = sorted(wanted_modules(ip_files, mods_defined))

    while frontier or mod_frontier:
        nxt, nxt_mods = [], []
        for name in frontier:
            if name in seen:
                continue
            seen.add(name)
            path = index.get(name)
            if path is None:
                continue  # not a package -- a class or enum scope; ignore
            ordered.append(path)
            nxt += sorted(refs([path]) - seen)
        for name in mod_frontier:
            if name in mods_seen:
                continue
            mods_seen.add(name)
            path = mod_index.get(name)
            if path is None:
                continue
            mods.append(path)
            mods_defined |= set(MOD_DECL.findall(strip(path.read_text(errors="ignore"))))
            nxt += sorted(refs([path]) - seen)
            nxt_mods += sorted(wanted_modules([path], mods_defined))
        frontier = sorted(set(nxt))
        mod_frontier = sorted(set(nxt_mods))

    # A package must be listed before whatever references it; we discovered
    # them the other way round, so reverse. (order_pkgs.py does the final,
    # authoritative topological sort once the files are in place.)
    ordered.reverse()

    for p in ordered + mods:
        print(p.relative_to(VENDOR))
    return 0


if __name__ == "__main__":
    sys.exit(main())
