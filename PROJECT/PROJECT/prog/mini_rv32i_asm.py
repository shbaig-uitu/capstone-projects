#!/usr/bin/env python3
"""
mini_rv32i_asm.py
------------------
Tiny assembler for the small subset of RV32I instructions needed
for the dual-core mailbox/GPIO/UART demonstration programs
(LUI, ADDI, LW, SW, JAL). Generates 32-bit binary strings, one
per line, in the exact format instruction_Mem.v expects for
$readmemb (no "0b" prefix, no spaces).
"""

def r(name):
    return int(name[1:])

def b(val, bits):
    return format(val & ((1 << bits) - 1), f'0{bits}b')

def lui(rd, imm20):
    # imm20 = the 20-bit upper immediate (already shifted conceptually)
    imm = (imm20 << 12) & 0xFFFFF000
    return b(imm >> 12, 20) + b(rd, 5) + '0110111'

def addi(rd, rs1, imm12):
    return b(imm12, 12) + b(rs1, 5) + '000' + b(rd, 5) + '0010011'

def lw(rd, rs1, imm12):
    return b(imm12, 12) + b(rs1, 5) + '010' + b(rd, 5) + '0000011'

def sw(rs2, rs1, imm12):
    imm11_5 = (imm12 >> 5) & 0x7F
    imm4_0  = imm12 & 0x1F
    return b(imm11_5, 7) + b(rs2, 5) + b(rs1, 5) + '010' + b(imm4_0, 5) + '0100011'

def jal(rd, imm):
    # imm must be even, +/-1MB range; we only ever use imm=0 (infinite self-loop)
    imm20   = (imm >> 20) & 0x1
    imm10_1 = (imm >> 1) & 0x3FF
    imm11   = (imm >> 11) & 0x1
    imm19_12= (imm >> 12) & 0xFF
    return b(imm20,1) + b(imm10_1,10) + b(imm11,1) + b(imm19_12,8) + b(rd,5) + '1101111'

def nop():
    return addi(0, 0, 0)


# ============================================================
# CORE 0 PROGRAM
#   x3 = 0x1000_0000                 (mailbox base)
#   x4 = 0x55                        (message value)
#   Mem[x3] = x4                     -> mailbox 0->1 data = 0x55
#   x8 = 0x2000_0000                 (gpio base)
#   x9 = 0xAA
#   Mem[x8] = x9                     -> gpio_out = 0xAA
#   loop forever
# ============================================================
core0 = [
    lui(3, 0x10000),
    addi(4, 0, 0x55),
    sw(4, 3, 0),
    lui(8, 0x20000),
    addi(9, 0, 0xAA),
    sw(9, 8, 0),
    jal(0, 0),
]

# ============================================================
# CORE 1 PROGRAM
#   x5 = 0x1000_0000                 (mailbox base)
#   NOPs                              (give core0 time to write first)
#   x6 = Mem[x5]                     -> read mailbox 0->1 data
#   x7 = 0x3000_0000                 (uart base)
#   Mem[x7] = x6                     -> echo mailbox value out via UART
#   loop forever
# ============================================================
core1 = [
    lui(5, 0x10000),
    nop(), nop(), nop(), nop(), nop(), nop(), nop(), nop(),
    lw(6, 5, 0),
    lui(7, 0x30000),
    sw(6, 7, 0),
    jal(0, 0),
]

with open('core0.txt', 'w') as f:
    for instr in core0:
        f.write(instr + '\n')

with open('core1.txt', 'w') as f:
    for instr in core1:
        f.write(instr + '\n')

print("core0.txt and core1.txt generated.")
print(f"core0: {len(core0)} instructions")
print(f"core1: {len(core1)} instructions")
