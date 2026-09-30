/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: riscv_types.sv
 * Description: Type definitions using pure Verilog-2005 constructs
 *              (No SystemVerilog packages for Yosys compatibility)
 */

`ifndef RISCV_TYPES_SV
`define RISCV_TYPES_SV

// ============================================================================
// Exception Types (using `define for Yosys compatibility)
// ============================================================================

// Exception codes
`define EXC_NONE              4'd0
`define EXC_INSTR_ADDR_FAULT  4'd0
`define EXC_LOAD_ADDR_FAULT   4'd4
`define EXC_BREAKPOINT        4'd3
`define EXC_LOAD_PAGE_FAULT   4'd13
`define EXC_STORE_PAGE_FAULT  4'd15
`define EXC_INSTR_PAGE_FAULT  4'd12
`define EXC_ECALL_M           4'd11

// Exception code values
parameter [3:0] EXC_CODE_NONE              = 4'd0;
parameter [3:0] EXC_CODE_INSTR_ADDR_FAULT  = 4'd0;
parameter [3:0] EXC_CODE_LOAD_ADDR_FAULT   = 4'd4;
parameter [3:0] EXC_CODE_BREAKPOINT        = 4'd3;
parameter [3:0] EXC_CODE_LOAD_PAGE_FAULT   = 4'd13;
parameter [3:0] EXC_CODE_STORE_PAGE_FAULT  = 4'd15;
parameter [3:0] EXC_CODE_INSTR_PAGE_FAULT  = 4'd12;
parameter [3:0] EXC_CODE_ECALL_M           = 4'd11;

// ============================================================================
// SATP Register Fields (Supervisor Address Translation and Protection)
// ============================================================================

// SATP bit layout: [31:22] ASID, [21:20] MODE, [19:0] PPN
// MODE: 0 = bare (no translation), 4 = SV32 (32-bit Sv32)
`define SATP_ASID_WIDTH  10
`define SATP_MODE_WIDTH  2
`define SATP_PPN_WIDTH   20

// ============================================================================
// MSTATUS Register Fields (Machine Status)
// ============================================================================

`define MSTATUS_SIE   1    // Supervisor Interrupt Enable
`define MSTATUS_SPIE  5    // Previous Supervisor IE
`define MSTATUS_SPP   8    // Previous Privilege Mode
`define MSTATUS_TVM   20   // Trap Virtual Memory
`define MSTATUS_TW    21   // Timeout Wait
`define MSTATUS_TSR  22   // Trap SRET

// ============================================================================
// Page Table Entry (PTE) Structure
// ============================================================================

// PTE for SV32 (32-bit virtual address, 34-bit physical):
// [31:20] Reserved, [19:0] PPN, [11:10] Reserved, [9] D, [8] A, [7] G, 
// [6] U, [5] X, [4] W, [3] R, [2] V

`define PTE_V_BIT     0    // Valid
`define PTE_R_BIT     1    // Read
`define PTE_W_BIT     2    // Write
`define PTE_X_BIT     3    // Execute
`define PTE_U_BIT     4    // User mode
`define PTE_G_BIT     5    // Global
`define PTE_A_BIT     8    // Accessed
`define PTE_D_BIT     9    // Dirty
`define PTE_PPN_HI    19   // PPN[9:0]
`define PTE_PPN_LO    10   // PPN[19:10]

// ============================================================================
// CSR Addresses
// ============================================================================

`define CSR_MSTATUS   12'h300   // Machine Status
`define CSR_MISA      12'h301   // Machine ISA
`define CSR_MIE       12'h304   // Machine Interrupt Enable
`define CSR_MTVEC     12'h305   // Machine Trap Vector
`define CSR_MEPC      12'h344   // Machine Exception PC
`define CSR_MCAUSE    12'h340   // Machine Cause
`define CSR_MTVAL     12'h341   // Machine Trap Value
`define CSR_MIP       12'h342   // Machine Interrupt Pending
`define CSR_SATP      12'h180   // Supervisor Address Translation
`define CSR_MCYCLE    12'hb00   // Machine Cycle Counter
`define CSR_MINSTRET  12'hb02   // Machine Instructions Retired

// ============================================================================
// Interrupt Causes (for MCAUSE)
// ============================================================================

`define IRQ_SOFTWARE  3   // Software interrupt
`define IRQ_TIMER    7   // Timer interrupt
`define IRQ_EXTERNAL 11  // External interrupt

`endif // RISCV_TYPES_SV