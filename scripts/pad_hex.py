#!/usr/bin/env python3
"""Pad a Verilog $readmemh image to a fixed word depth without changing existing words."""
import sys
from pathlib import Path

def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: pad_hex.py <hex-file> <depth>")
    path = Path(sys.argv[1])
    depth = int(sys.argv[2])
    lines = [line.strip() for line in path.read_text().splitlines() if line.strip()]
    if len(lines) > depth:
        raise SystemExit(f"{path} has {len(lines)} words, exceeds depth {depth}")
    if len(lines) < depth:
        lines.extend(["00000013"] * (depth - len(lines)))  # RV32I NOP (ADDI x0,x0,0)
        path.write_text("\n".join(lines) + "\n")
    print(f"Padded {path} to {depth} words")

if __name__ == "__main__":
    main()
