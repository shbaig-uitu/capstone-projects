/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: riscv_defines.sv
 * Description: Global defines, macros, and parameters for RV32I SoC
 */

`ifndef RISCV_DEFINES_SV
`define RISCV_DEFINES_SV

// ============================================================================
// ISA Parameters
// ============================================================================

// RISC-V Base Integer ISA (RV32I)
`define XLEN 32              // Register width
`define ILEN 32              // Instruction width
`define ADDR_WIDTH 32        // Address width
`define DATA_WIDTH 32        // Data width

// Register File Depth
`define NUM_REGISTERS 32     // x0-x31

// Memory Configuration
`define INST_MEM_DEPTH 4096  // Instruction memory depth (words)
`define DATA_MEM_DEPTH 4096  // Data memory depth (words)
`define INST_MEM_SIZE (4 * `INST_MEM_DEPTH)  // Bytes

// ============================================================================
// Virtual Memory Parameters
// ============================================================================

// Page Configuration
`define PAGE_SIZE 4096                    // 4KB pages
`define PAGE_OFFSET_WIDTH 12              // log2(PAGE_SIZE)
`define VIRT_ADDR_WIDTH 32
`define PHYS_ADDR_WIDTH 32

// TLB Configuration
`define TLB_ENTRIES 16                    // Small TLB for demo
`define TLB_INDEX_WIDTH 4                 // log2(TLB_ENTRIES)

// Page Table Configuration
`define PAGE_TABLE_ENTRIES 1024           // 1K entries per level
`define PAGE_TABLE_ENTRY_WIDTH 32         // 32-bit PTE
`define PTE_PPN_WIDTH 20                  // Physical page number width
`define PTE_FLAG_WIDTH 12                 // Flags (V, R, W, X, etc.)

// ============================================================================
// AXI4-Lite Configuration
// ============================================================================

`define AXI_ADDR_WIDTH 32
`define AXI_DATA_WIDTH 32
`define AXI_STRB_WIDTH 4

// ============================================================================
// Control and Status Registers (CSRs)
// ============================================================================

// MMU Control CSRs
`define CSR_SATP       12'h180            // Supervisor Address Translation and Protection
`define CSR_STATUS     12'h300            // Machine Status

// Page Fault Exception Codes
`define EXC_INST_FAULT  0                 // Instruction address misaligned
`define EXC_DATA_FAULT  5                 // Load address misaligned

// ============================================================================
// Instruction Opcodes (RV32I)
// ============================================================================

`define OP_LUI         7'b0110111
`define OP_AUIPC       7'b0010111
`define OP_JAL         7'b1101111
`define OP_JALR        7'b1100111
`define OP_BRANCH      7'b1100011
`define OP_LOAD        7'b0000011
`define OP_STORE       7'b0100011
`define OP_IMM         7'b0010011
`define OP_REG         7'b0110011
`define OP_FENCE       7'b0001111
`define OP_SYSTEM      7'b1110011

// Load/Store function codes
`define FUNCT3_LB      3'b000
`define FUNCT3_LH      3'b001
`define FUNCT3_LW      3'b010
`define FUNCT3_LBU     3'b100
`define FUNCT3_LHU     3'b101

`define FUNCT3_SB      3'b000
`define FUNCT3_SH      3'b001
`define FUNCT3_SW      3'b010

// ============================================================================
// Debugging & Simulation Macros
// ============================================================================

`define DEBUG_ENABLE 1

`ifdef DEBUG_ENABLE
  `define DEBUG_PRINT(msg) $display("[%0t] %s", $time, msg)
  `define DEBUG_INFO(fmt, args) $display("[%0t] " fmt, $time, args)
`else
  `define DEBUG_PRINT(msg)
  `define DEBUG_INFO(fmt, args)
`endif

// Simulation time constants
`define CLK_PERIOD 10        // 10ns clock = 100MHz

`endif // RISCV_DEFINES_SV
