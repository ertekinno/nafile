#!/usr/bin/env python3
"""Print the sources or family name from sources/config.yaml (used by the Makefile)."""
import re
import sys
from pathlib import Path

config = Path(__file__).resolve().parent.parent / "sources" / "config.yaml"
text = config.read_text(encoding="utf-8")

if "--family" in sys.argv:
    match = re.search(r"^familyName:\s*\"?([^\"\n]+)\"?", text, re.M)
    print(match.group(1).strip() if match else "")
elif "--sources" in sys.argv:
    block = re.search(r"^sources:\s*\n((?:\s+-\s*.+\n?)+)", text, re.M)
    names = re.findall(r"-\s*(.+)", block.group(1)) if block else []
    print(" ".join("sources/" + n.strip() for n in names))
