#!/usr/bin/env python3
"""Generate a factual README.md for a scaffolded IP.

    ./IP/scripts/gen_readme.py <ip>

Everything printed is extracted from the IP itself -- port groups from the
generated tb.sv, doc files from docs/, external packages from rtl/files.f.

Deliberately does NOT invent spec analysis. Six IPs (gpio, pwm, uart, i2c,
spi_host, rv_plic) have hand-written "things this IP will make you think about"
sections; the rest say plainly that they are not curated yet, rather than
padding with plausible-sounding guesses.
"""
import re
import sys
from pathlib import Path

IP_ROOT = Path(__file__).resolve().parent.parent

TIERS = {
    "rv_timer": ("starter", "One counter, one comparator, one interrupt"),
    "pattgen": ("starter", "Two channels shifting a programmed pattern out"),
    "aon_timer": ("starter", "Wakeup + watchdog counters in the always-on domain"),
    "hmac": ("starter/intermediate", "Streaming hash; the reference model is a library call"),
    "adc_ctrl": ("intermediate", "Sampling FSM with filters and a wakeup path"),
    "mbx": ("intermediate", "Doorbell/inbox/outbox between two bus masters"),
    "dma": ("intermediate", "Address generation and bus mastering; it initiates traffic"),
    "spi_device": ("advanced", "Flash/passthrough/generic modes -- effectively three IPs"),
    "usbdev": ("advanced", "Full USB 2.0 FS device; needs a link-layer model"),
    "aes": ("advanced/security", "Masked datapath; needs a reference model and DOM awareness"),
    "kmac": ("advanced/security", "Keccak core with masking and an app interface"),
    "csrng": ("advanced/security", "NIST SP 800-90A DRBG; reference model essentially mandatory"),
    "otbn": ("advanced/security", "A whole processor -- ISA-level verification"),
    "flash_ctrl": ("advanced", "Scrambling, ECC, program/erase, lifecycle interaction"),
    "pwrmgr": ("advanced", "Sleep/wake FSM across power domains"),
    "pinmux": ("intermediate", "Large muxing matrix plus wakeup detectors"),
    "rv_dm": ("advanced", "RISC-V debug over JTAG; needs a DTM/DMI model"),
}

DOC_ORDER = [
    ("theory_of_operation.md", "How it works -- start here"),
    ("registers.md", "Every register and field"),
    ("interfaces.md", "Port list and parameters"),
    ("programmers_guide.md", "Expected software sequences"),
    ("checklist.md", "Upstream's sign-off checklist"),
]


def main():
    ip = sys.argv[1]
    d = IP_ROOT / ip
    tb = (d / "verification/tb/tb.sv").read_text()
    files_f = (d / "rtl/files.f").read_text()

    autogen = "ip_autogen" in files_f
    src = (f"vendor/opentitan/hw/top_earlgrey/ip_autogen/{ip}/" if autogen
           else f"vendor/opentitan/hw/ip/{ip}/")

    ports = re.findall(r"^\s+\.(\w+)\s*\(", tb, re.M)
    intrs = [p for p in ports if p.startswith("intr_")]
    cios = [p for p in ports if p.startswith("cio_")]
    has_tl = any(p in ("tl_i", "tl_o") for p in ports)
    has_alert = any("alert_" in p for p in ports)
    has_racl = any("racl_" in p for p in ports)
    clks = [p for p in ports if p.startswith("clk_")]

    deps = re.findall(r"^//\s+(\S+\.sv)\s+<-\s+(\S+)$", files_f, re.M)
    rtl_n = len(list((d / "rtl").glob("*.sv")))
    tier, why = TIERS.get(ip, ("uncategorised", ""))

    L = []
    A = L.append
    A(f"# {ip}")
    A("")
    A(f"> ⚠️ **This README is auto-generated** by `IP/scripts/gen_readme.py` and")
    A("> contains only facts extracted from the RTL and the upstream docs. It has")
    A("> **not** been curated with spec analysis. For examples of what a curated")
    A("> IP page looks like, see [`../uart/README.md`](../uart/README.md) or")
    A("> [`../rv_plic/README.md`](../rv_plic/README.md). Improving this file as you")
    A("> read the spec is a legitimate part of the exercise.")
    A("")
    A("| | |")
    A("|---|---|")
    A(f"| **Tier** | {tier}{' — ' + why if why else ''} |")
    A(f"| **Source** | `{src}` @ `365c167e` |")
    A(f"| **Top module** | `{ip}` (`rtl/{ip}.sv`) |")
    A(f"| **RTL files** | {rtl_n} (including {len(deps)} externally-owned package{'s' if len(deps) != 1 else ''}) |")
    A(f"| **DUT ports** | {len(ports)} |")
    A(f"| **Bus** | {'TL-UL device' if has_tl else 'no TL-UL port'} |")
    A(f"| **Interrupts** | {len(intrs) if intrs else 'none'} |")
    A(f"| **Clock domains** | {len(clks)} ({', '.join('`' + c + '`' for c in clks)}) |")
    A("| **Compile check** | 🔲 unverified — run `sim/run_compile.sh` |")
    A("| **Environment built** | 🔲 not started |")
    A("")
    if autogen:
        A("> ⚠️ **Generated IP.** The upstream source of truth is the template at")
        A(f"> `hw/ip_templates/{ip}/`, instantiated for Earl Grey. What is copied here")
        A("> is the *generated Earl Grey instance*, which is what you want — it matches")
        A("> the chip the SoC track verifies. Do not look for it under `hw/ip/`.")
        A("")

    if deps:
        A("---")
        A("")
        A("## External dependencies")
        A("")
        A("This IP references packages owned by *other* IPs, so they are copied into")
        A("`rtl/` and listed first in `rtl/files.f`:")
        A("")
        A("| Package | From |")
        A("|---|---|")
        for f, srcp in deps:
            A(f"| `{f}` | `{srcp}` |")
        A("")
        A("They are deliberately **not** in `IP/common/` — that carries what *every*")
        A("IP needs, not what *any* IP might need. See")
        A("[`../common/README.md`](../common/README.md). Resolved automatically by")
        A("`scripts/resolve_deps.py`.")
        A("")

    A("---")
    A("")
    A("## Interfaces")
    A("")
    A("| Group | Present |")
    A("|---|---|")
    A(f"| Clock/reset | {', '.join('`' + c + '`' for c in clks)} |")
    A(f"| TL-UL bus | {'`tl_i`, `tl_o`' if has_tl else '—'} |")
    A(f"| Chip IO (`cio_*`) | {len(cios)} port(s)" + (f": {', '.join('`' + c + '`' for c in cios[:8])}" + (" …" if len(cios) > 8 else "") if cios else " — none") + " |")
    A(f"| Interrupts | {', '.join('`' + i + '`' for i in intrs) if intrs else '— none'} |")
    A(f"| Alerts | {'yes' if has_alert else '— none'} |")
    A(f"| RACL | {'yes' if has_racl else '— none'} |")
    A("")
    A("Full port list with types: `verification/tb/tb.sv`, or `docs/interfaces.md`.")
    A("")
    A("---")
    A("")
    A("## Documentation")
    A("")
    A("| File | Contents |")
    A("|---|---|")
    for fn, desc in DOC_ORDER:
        if (d / "docs" / fn).exists():
            A(f"| [`docs/{fn}`](docs/{fn}) | {desc} |")
    if (d / "docs" / f"{ip}.hjson").exists():
        A(f"| [`docs/{ip}.hjson`](docs/{ip}.hjson) | Machine-readable register description — **generate your RAL from this** |")
    for extra in sorted((d / "docs").glob("*.svg")):
        A(f"| [`docs/{extra.name}`](docs/{extra.name}) | Diagram |")
    A("")
    book = (f"https://opentitan.org/book/hw/top_earlgrey/ip_autogen/{ip}/" if autogen
            else f"https://opentitan.org/book/hw/ip/{ip}/")
    A(f"Online: {book}")
    A("")
    A("> These track upstream HEAD, not our pinned commit. For exact behaviour")
    A("> always read the local `docs/` and the RTL.")
    A("")
    A("---")
    A("")
    A("## Getting started")
    A("")
    A("```bash")
    A("source scripts/activate_env.sh")
    A(f"cd IP/{ip}/sim")
    A("./run_compile.sh          # elaborate + run the do-nothing test")
    A("```")
    A("")
    A("Then follow the five steps in [`verification/README.md`](verification/README.md).")
    A("Your first real deliverable is `verification/testplan.md`, written from")
    A("`docs/theory_of_operation.md` — not from this file.")
    print("\n".join(L))


if __name__ == "__main__":
    main()
