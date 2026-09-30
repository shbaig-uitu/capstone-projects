/**
 * RISC-V SoC UVM Testbench - Package Definition
 * 
 * File: uvm_pkg.sv
 * Description: UVM package containing all verification components
 *              - Interfaces, agents, monitors, drivers, scoreboards
 *              - Coverage collectors
 *              - Test scenarios and sequences
 */

`include "uvm_macros.svh"

package riscv_uvm_pkg;
  import uvm_pkg::*;

  `include "uvm_version.svh"
  `define UVM_VERSION 1_2

  // ============================================================================
  // Parameter Definitions
  // ============================================================================
  
  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32;
  parameter ILEN = 32;
  parameter NUM_REGS = 32;

  // ============================================================================
  // Typedefs and Enumerations
  // ============================================================================

  // Exception codes
  typedef enum logic [3:0] {
    EXC_NONE              = 4'd0,
    EXC_INSTR_FAULT       = 4'd0,
    EXC_LOAD_FAULT        = 4'd4,
    EXC_STORE_FAULT       = 4'd6,
    EXC_BREAKPOINT        = 4'd3,
    EXC_LOAD_PAGE_FAULT   = 4'd13,
    EXC_STORE_PAGE_FAULT  = 4'd15,
    EXC_INSTR_PAGE_FAULT  = 4'd12,
    EXC_ECALL_M           = 4'd11
  } exception_t;

  // CSR Operations
  typedef enum logic [1:0] {
    CSR_READ  = 2'b00,
    CSR_WRITE = 2'b01,
    CSR_SET   = 2'b10,
    CSR_CLEAR = 2'b11
  } csr_op_t;

  // Memory Transaction Types
  typedef enum logic [2:0] {
    MEM_READ   = 3'b000,
    MEM_WRITE  = 3'b001,
    MEM_FETCH  = 3'b010,
    MEM_FLUSH  = 3'b011
  } mem_trans_type_t;

  // Test Phases
  typedef enum {
    RESET_PHASE,
    INITIALIZATION_PHASE,
    BASIC_INSTRUCTION_PHASE,
    MEMORY_ACCESS_PHASE,
    CSR_ACCESS_PHASE,
    EXCEPTION_PHASE,
    STRESS_PHASE,
    COVERAGE_PHASE
  } test_phase_t;

  // ============================================================================
  // UVM Components (included in this package)
  // ============================================================================

  // Include all UVM components in proper order
  `include "uvm_riscv_if.sv"
  `include "uvm_riscv_transaction.sv"
  `include "uvm_riscv_sequencer.sv"
  `include "uvm_riscv_driver.sv"
  `include "uvm_riscv_monitor.sv"
  `include "uvm_riscv_agent.sv"
  `include "uvm_riscv_scoreboard.sv"
  `include "uvm_riscv_coverage.sv"
  `include "uvm_riscv_sequences.sv"
  `include "uvm_riscv_env.sv"
  `include "uvm_riscv_test.sv"

endpackage : riscv_uvm_pkg

`endif // UVM_PKG_SV
