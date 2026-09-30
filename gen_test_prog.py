#!/usr/bin/env python3
"""
Builds the directed MMU test program:
  - VPN 0 is mapped (by the testbench, over AXI) to PPN 3, before the
    core is released from reset.
  - VPN 4 is deliberately left UNMAPPED to exercise the page-fault path.

Program (byte address : instruction):
  0  : ADDI x1, x0, 100      ; x1 = 100
  4  : SW   x1, 0(x0)        ; VA 0   -> VPN0 -> TLB MISS (valid, fills TLB)
  8  : LW   x2, 0(x0)        ; VA 0   -> VPN0 -> TLB HIT,  x2 should = 100
  12 : ADDI x3, x0, 55       ; x3 = 55
  16 : SW   x3, 4(x0)        ; VA 4   -> VPN0 -> TLB HIT (same page)
  20 : LW   x4, 4(x0)        ; VA 4   -> VPN0 -> TLB HIT,  x4 should = 55
  24 : ADDI x7, x0, 1024     ; x7 = 1024 (VPN = 1024>>8 = 4, unmapped)
  28 : LW   x8, 0(x7)        ; VA1024 -> VPN4 -> PAGE FAULT, x8 = 0xDEAD_DEAD
  32 : ADDI x9, x0, 77       ; x9 = 77
  36 : SW   x9, 0(x7)        ; VA1024 -> VPN4 -> PAGE FAULT (write suppressed)
  40 : JAL  x0, 0            ; infinite self-loop -> marks "program done"
"""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from asm import ADDI, SW, LW, JAL

prog = [
    ADDI(1, 0, 100),
    SW(1, 0, 0),
    LW(2, 0, 0),
    ADDI(3, 0, 55),
    SW(3, 0, 4),
    LW(4, 0, 4),
    ADDI(7, 0, 1024),
    LW(8, 7, 0),
    ADDI(9, 0, 77),
    SW(9, 7, 0),
    JAL(0, 0),
]

out_path = os.path.join(os.path.dirname(__file__), "test_prog.hex")
with open(out_path, "w") as f:
    for instr in prog:
        f.write(f"{instr & 0xFFFFFFFF:08x}\n")

print(f"Wrote {len(prog)} instructions to {out_path}")
for i, instr in enumerate(prog):
    print(f"  {i*4:3d}: {instr:08x}")
