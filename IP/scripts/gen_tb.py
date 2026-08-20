#!/usr/bin/env python3
"""Generate a compile-check tb.sv from an IP's module header.

    ./IP/scripts/gen_tb.py <ip> [--src <vendor-relative-rtl-dir>]

Parses `module <ip> ... ( ... );`, then emits a testbench that declares every
port, ties every input to a CONSTANT, instantiates the DUT and starts UVM.

Tie-off rules, in priority order:
    clk_*        -> a generated clock (slow domains get a slower one)
    rst_*_ni     -> the generated reset
    tl_h2d_t     -> tlul_pkg::TL_H2D_DEFAULT
    alert_rx_t   -> '{default: prim_alert_pkg::ALERT_RX_DEFAULT}
    racl_policy_vec_t -> top_racl_pkg::RACL_POLICY_VEC_DEFAULT
    everything else   -> '0

'0 is deliberate: it works on packed structs and vectors alike, and a constant
is always safer than a float. An X from an undriven input propagates into the
register file and trips the TL-UL dKnown assertions, with the failure surfacing
long after the real cause.

The output is a STARTING POINT. It compiles; it does not stimulate anything.
Ports needing a non-zero idle level (open-drain buses idle HIGH, serial lines
idle HIGH) are flagged with a TODO rather than guessed at.
"""
import re
import sys
from pathlib import Path

IP_ROOT = Path(__file__).resolve().parent.parent
VENDOR = IP_ROOT.parent / "vendor" / "opentitan"

# Chip IO that idles HIGH on a real bus (open-drain I2C, serial RX). Tying it
# low is legal for a compile check but models a bus that can never idle, so
# flag it rather than leave it silently wrong. Restricted to cio_* so it does
# not catch alert_rx_i, which is a differential pair with its own default.
IDLE_HIGH = re.compile(r"^cio_.*(scl|sda|rx)")


def find_src(ip, argv):
    if "--src" in argv:
        return VENDOR / argv[argv.index("--src") + 1]
    for cand in (VENDOR / "hw/ip" / ip / "rtl",
                 VENDOR / "hw/top_earlgrey/ip_autogen" / ip / "rtl"):
        if cand.is_dir():
            return cand
    sys.exit(f"no RTL dir for {ip}")


def header(text, ip):
    """Return the port-list body of `module <ip> ... ( ... );`."""
    m = re.search(rf"^\s*module\s+{ip}\b", text, re.M)
    if not m:
        sys.exit(f"no module {ip} found")
    i = m.end()
    # Skip an optional import list and an optional #(...) parameter block by
    # walking to the first '(' that is not part of '#('.
    depth, start = 0, None
    while i < len(text):
        c = text[i]
        if c == "#" and text[i + 1:i + 2] == "(":  # parameter block: skip it
            i += 1
            d = 0
            while i < len(text):
                if text[i] == "(":
                    d += 1
                elif text[i] == ")":
                    d -= 1
                    if d == 0:
                        break
                i += 1
        elif c == "(":
            if depth == 0:
                start = i + 1
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return text[start:i]
        i += 1
    sys.exit("could not parse port list")


PORT = re.compile(
    r"^\s*(input|output|inout)\s+(?:wire\s+|var\s+)?(.*?)"
    r"([A-Za-z_]\w*)\s*(\[[^\]]*\])?\s*$"
)


def parse_ports(body):
    body = re.sub(r"//[^\n]*", "", body)
    body = re.sub(r"/\*.*?\*/", "", body, flags=re.S)
    ports, direction = [], None
    for chunk in body.split(","):
        chunk = chunk.strip()
        if not chunk:
            continue
        m = PORT.match(chunk)
        if m:
            direction, typ, name, unpacked = m.groups()
            ports.append((direction, typ.strip(), name, unpacked or ""))
        else:
            # continuation of the previous direction, e.g. `output a, b, c`
            m2 = re.match(r"^(.*?)([A-Za-z_]\w*)\s*(\[[^\]]*\])?$", chunk)
            if m2 and direction:
                typ, name, unpacked = m2.groups()
                ports.append((direction, typ.strip(), name, unpacked or ""))
    return ports


def module_imports(text, ip, src):
    """Packages the module header imports, plus the IP's own reg package.

    `module uart import uart_reg_pkg::*; #(...)` makes NumAlerts visible inside
    the module only. tb declares ports of the same width, so it needs the same
    imports or every parameterised width fails to compile.
    """
    m = re.search(rf"^\s*module\s+{ip}\b(.*?)[(#]", text, re.M | re.S)
    found = re.findall(r"import\s+([A-Za-z_]\w*)\s*::", m.group(1)) if m else []

    # The reg package holds NumAlerts / NumIOs / NumSrc and friends. Only add
    # it if the IP actually defines one -- not every IP does.
    reg = f"{ip}_reg_pkg"
    if reg not in found and (src / f"{reg}.sv").exists():
        found.append(reg)
    return found


def decl_type(typ):
    return typ if typ.strip() else "logic"


def tie(name, typ):
    if "tl_h2d_t" in typ:
        return "tlul_pkg::TL_H2D_DEFAULT"
    if "alert_rx_t" in typ:
        return "'{default: prim_alert_pkg::ALERT_RX_DEFAULT}"
    if "racl_policy_vec_t" in typ:
        return "top_racl_pkg::RACL_POLICY_VEC_DEFAULT"
    return "'0"


def main():
    ip = sys.argv[1]
    src = find_src(ip, sys.argv)
    text = (src / f"{ip}.sv").read_text(errors="ignore")
    ports = parse_ports(header(text, ip))

    clks = [p for p in ports if p[2].startswith("clk_")]
    rsts = [p for p in ports if re.match(r"^rst_.*n?i?$", p[2]) and p[0] == "input"]
    special = {p[2] for p in clks} | {p[2] for p in rsts}

    L = []
    A = L.append
    A("// Copyright lowRISC contributors (OpenTitan project).")
    A("// Licensed under the Apache License, Version 2.0, see LICENSE for details.")
    A("// SPDX-License-Identifier: Apache-2.0")
    A("//")
    A(f"// {ip} -- COMPILE-CHECK TESTBENCH   (generated by IP/scripts/gen_tb.py)")
    A("//")
    A("// A skeleton, not a verification environment. It proves the RTL and its")
    A("// dependencies elaborate and a UVM test can start and finish. Every input")
    A("// is tied to a constant; nothing is stimulated and nothing is checked.")
    A("// Building the environment is the exercise -- see ../README.md.")
    A("")
    A("module tb;")
    A("")
    A("  import uvm_pkg::*;")
    A(f"  import {ip}_test_pkg::*;")
    # The module header imports its own packages, so parameters like NumAlerts
    # resolve inside the module but NOT here. Replicate those imports, or every
    # port whose width mentions a parameter fails to compile.
    for pkg in module_imports(text, ip, src):
        A(f"  import {pkg}::*;")
    A("  `include \"uvm_macros.svh\"")
    A("")

    # ---- clocks and resets
    A("  // Clocks. The main bus clock is 100 MHz to match Earl Grey; slow")
    A("  // domains (aon / core / usb) get their own so the ratio is realistic.")
    A("  logic clk, rst_n;")
    A("")
    A("  initial begin")
    A("    clk = 1'b0;")
    A("    forever #5ns clk = ~clk;")
    A("  end")
    A("")
    extra_clks = [c for c in clks if c[2] != "clk_i"]
    for _, _, name, _ in extra_clks:
        slow = any(k in name for k in ("aon", "core", "slow", "lc", "esc"))
        per = "20ns" if slow else "5ns"
        A(f"  logic {name}_tb;")
        A("  initial begin")
        A(f"    {name}_tb = 1'b0;")
        A(f"    forever #{per} {name}_tb = ~{name}_tb;")
        A("  end")
        A("")
    A("  initial begin")
    A("    rst_n = 1'b0;")
    A("    repeat (10) @(posedge clk);")
    A("    rst_n = 1'b1;")
    A("  end")
    A("")

    # ---- port declarations
    A("  // Port declarations. Inputs are tied to constants -- never floating.")
    todo = []
    for direction, typ, name, unpacked in ports:
        if name in special:
            continue
        t = decl_type(typ)
        if direction == "input":
            A(f"  {t} {name} {unpacked}= {tie(name, typ)};".replace("  =", " ="))
            if IDLE_HIGH.search(name):
                todo.append(name)
        elif direction == "inout":
            A(f"  wire {name} {unpacked};")
        else:
            A(f"  {t} {name} {unpacked};")
    A("")
    if todo:
        A("  // TODO(trainee): these lines idle HIGH on a real bus (open-drain or")
        A("  // serial idle). They are tied low above only so the compile check is")
        A("  // deterministic -- fix them before you drive any traffic:")
        for n in todo:
            A(f"  //   {n}")
        A("")

    # ---- DUT
    A(f"  {ip} dut (")
    conns = []
    for direction, typ, name, _ in ports:
        if name in {c[2] for c in clks}:
            tgt = "clk" if name == "clk_i" else f"{name}_tb"
        elif name in {r[2] for r in rsts}:
            tgt = "rst_n"
        else:
            tgt = name
        conns.append(f"    .{name} ({tgt})")
    A(",\n".join(conns))
    A("  );")
    A("")

    # ---- UVM entry
    A("  tb_clk_if clk_if (.clk(clk), .rst_n(rst_n));")
    A("")
    A("  initial begin")
    A("    uvm_config_db#(virtual tb_clk_if)::set(null, \"*\", \"clk_if\", clk_if);")
    A("    run_test();")
    A("  end")
    A("")
    A("  initial begin")
    A("    #1ms;")
    A("    `uvm_fatal(\"TB\", \"timeout -- simulation ran for 1ms with no test completion\")")
    A("  end")
    A("")
    A("endmodule")
    print("\n".join(L))


if __name__ == "__main__":
    main()
