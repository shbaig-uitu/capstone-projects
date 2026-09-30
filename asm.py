#!/usr/bin/env python3
"""
Minimal RV32I assembler for exactly the instructions this core supports.
Used to hand-build the MMU test program precisely (bit-accurate), instead
of risking hand-computed hex.
"""

def r(bits, msb, lsb):
    return (bits >> lsb) & ((1 << (msb - lsb + 1)) - 1)

def rtype(funct7, rs2, rs1, funct3, rd, opcode):
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def itype(imm, rs1, funct3, rd, opcode):
    imm &= 0xFFF
    return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def stype(imm, rs2, rs1, funct3, opcode):
    imm &= 0xFFF
    imm11_5 = (imm >> 5) & 0x7F
    imm4_0  = imm & 0x1F
    return (imm11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm4_0 << 7) | opcode

def btype(imm, rs2, rs1, funct3, opcode):
    # imm is byte offset, must be even
    imm &= 0x1FFF
    b12   = (imm >> 12) & 1
    b10_5 = (imm >> 5) & 0x3F
    b4_1  = (imm >> 1) & 0xF
    b11   = (imm >> 11) & 1
    return (b12 << 31) | (b10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (b4_1 << 8) | (b11 << 7) | opcode

def utype(imm, rd, opcode):
    return (imm & 0xFFFFF000) | (rd << 7) | opcode

def jtype(imm, rd, opcode):
    imm &= 0x1FFFFF
    b20    = (imm >> 20) & 1
    b10_1  = (imm >> 1) & 0x3FF
    b11    = (imm >> 11) & 1
    b19_12 = (imm >> 12) & 0xFF
    return (b20 << 31) | (b19_12 << 12) | (b11 << 20) | (b10_1 << 21) | (rd << 7) | opcode

# opcodes
OP_R, OP_I, OP_LOAD, OP_STORE, OP_BR, OP_JAL, OP_JALR, OP_LUI, OP_AUIPC = \
  0b0110011, 0b0010011, 0b0000011, 0b0100011, 0b1100011, 0b1101111, 0b1100111, 0b0110111, 0b0010111

def ADDI(rd, rs1, imm): return itype(imm, rs1, 0b000, rd, OP_I)
def ANDI(rd, rs1, imm): return itype(imm, rs1, 0b111, rd, OP_I)
def ADD(rd, rs1, rs2):  return rtype(0b0000000, rs2, rs1, 0b000, rd, OP_R)
def SUB(rd, rs1, rs2):  return rtype(0b0100000, rs2, rs1, 0b000, rd, OP_R)
def LW(rd, rs1, imm):   return itype(imm, rs1, 0b010, rd, OP_LOAD)
def SW(rs2, rs1, imm):  return stype(imm, rs2, rs1, 0b010, OP_STORE)
def BEQ(rs1, rs2, imm): return btype(imm, rs2, rs1, 0b000, OP_BR)
def BNE(rs1, rs2, imm): return btype(imm, rs2, rs1, 0b001, OP_BR)
def JAL(rd, imm):       return jtype(imm, rd, OP_JAL)
def LUI(rd, imm):       return utype(imm, rd, OP_LUI)

if __name__ == "__main__":
    pass
