/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: exception_handler.sv
 * Description: Exception and Interrupt Handler Module
 *              Manages exception vector generation, trap handling,
 *              and exception priority resolution.
 *              Coordinates between core, MMU, CSR unit, and external interrupts.
 */

`include "../include/riscv_defines.sv"
`include "../include/riscv_types.sv"

module exception_handler (
  input  logic                clk,
  input  logic                rst_n,
  
  // Core Exception Signals (from rv32i_core)
  input  logic                core_exception_valid,
  input  logic [3:0]          core_exception_code,
  input  logic [`ADDR_WIDTH-1:0]  core_exception_badaddr,
  input  logic [`ADDR_WIDTH-1:0]  core_pc,
  
  // MMU Page Fault Signals
  input  logic                mmu_inst_page_fault,
  input  logic [`ADDR_WIDTH-1:0]  mmu_fault_addr,
  input  logic                mmu_data_page_fault,
  input  logic [`ADDR_WIDTH-1:0]  mmu_data_fault_addr,
  
  // CSR Interface
  input  logic [`DATA_WIDTH-1:0]  mstatus,
  input  logic [`DATA_WIDTH-1:0]  mie,          // Machine Interrupt Enable
  input  logic [`DATA_WIDTH-1:0]  mip,          // Machine Interrupt Pending
  input  logic [`DATA_WIDTH-1:0]  mtvec,        // Trap Vector Base Address
  
  // External Interrupt Signals
  input  logic                ext_timer_interrupt,
  input  logic                ext_software_interrupt,
  input  logic                ext_external_interrupt,
  
  // Output Exception Signals
  output logic                exception_valid,
  output logic [3:0]          exception_code,
  output logic [`ADDR_WIDTH-1:0]  exception_badaddr,
  output logic [`ADDR_WIDTH-1:0]  exception_pc,
  
  // Trap Handler Control
  output logic                trap_taken,
  output logic [`ADDR_WIDTH-1:0]  trap_handler_addr,
  output logic                trap_is_interrupt,
  output logic [3:0]          trap_cause
);

  logic                       exc_valid_w;      // combinational signal for exception valid
  
  // ============================================================================
  // Exception Priority Resolution (RISC-V Privileged ISA Spec)
  // ============================================================================
  
  // Exception/Interrupt priority (higher number = higher priority):
  // 1. Synchronous exceptions (from core execution)
  // 2. Instruction page faults
  // 3. Load page faults
  // 4. Store page faults
  // 5. Interrupts (software > timer > external)
  
  logic                       has_sync_exception;
  logic                       has_inst_page_fault;
  logic                       has_data_page_fault;
  logic                       has_software_interrupt;
  logic                       has_timer_interrupt;
  logic                       has_external_interrupt;
  
  logic [3:0]                 selected_exception_code;
  logic [`ADDR_WIDTH-1:0]     selected_exception_badaddr;
  logic                       selected_is_interrupt;
  
  // ============================================================================
  // Exception Detection Logic
  // ============================================================================
  
  assign has_sync_exception       = core_exception_valid;
  assign has_inst_page_fault      = mmu_inst_page_fault;
  assign has_data_page_fault      = mmu_data_page_fault;
  
  // Interrupt Detection (only if interrupts are enabled in MSTATUS and MIE)
  assign has_software_interrupt   = mstatus[1] && mie[3] && mip[3];
  assign has_timer_interrupt      = mstatus[1] && mie[7] && mip[7];
  assign has_external_interrupt   = mstatus[1] && mie[11] && mip[11];
  
  // ============================================================================
  // Priority Resolution
  // ============================================================================
  
  always_comb begin
    // Default: no exception
    exception_valid        = 1'b0;
    selected_exception_code = EXC_NONE;
    selected_exception_badaddr = '0;
    selected_is_interrupt  = 1'b0;
    
    // Priority order (highest to lowest):
    // Synchronous exceptions have highest priority
    if (has_sync_exception) begin
      exc_valid_w         = 1'b1;
      selected_exception_code = core_exception_code;
      selected_exception_badaddr = core_exception_badaddr;
      selected_is_interrupt = 1'b0;
    end
    // Instruction page faults
    else if (has_inst_page_fault) begin
      exc_valid_w         = 1'b1;
      selected_exception_code = `EXC_INSTR_PAGE_FAULT;
      selected_exception_badaddr = mmu_fault_addr;
      selected_is_interrupt = 1'b0;
    end
    // Load/Store page faults (Data access)
    else if (has_data_page_fault) begin
      exc_valid_w         = 1'b1;
      selected_exception_code = `EXC_LOAD_PAGE_FAULT;  // Generalized
      selected_exception_badaddr = mmu_data_fault_addr;
      selected_is_interrupt = 1'b0;
    end
    // Interrupts (if interrupts enabled and no sync exceptions)
    else if (has_software_interrupt) begin
      exc_valid_w         = 1'b1;
      selected_exception_code = 4'd3;  // Software interrupt
      selected_is_interrupt = 1'b1;
    end
    else if (has_timer_interrupt) begin
      exc_valid_w         = 1'b1;
      selected_exception_code = 4'd7;  // Timer interrupt
      selected_is_interrupt = 1'b1;
    end
    else if (has_external_interrupt) begin
      exc_valid_w         = 1'b1;
      selected_exception_code = 4'd11; // External interrupt
      selected_is_interrupt = 1'b1;
    end
  end
  
  // ============================================================================
  // Trap Handler Address Calculation
  // ============================================================================
  
  // RISC-V supports two trap addressing modes:
  // - Direct: All exceptions go to mtvec (BASE address)
  // - Vectored: Interrupts go to mtvec + 4*cause
  
  logic                       mtvec_mode;     // 0=Direct, 1=Vectored
  logic [`ADDR_WIDTH-1:0]     mtvec_base;
  
  assign mtvec_mode = mtvec[1:0];    // MODE field in MTVEC
  assign mtvec_base = {mtvec[31:2], 2'b00};  // BASE field
  
  always_comb begin
    trap_taken = 1'b0;
    trap_handler_addr = '0;
    trap_is_interrupt = 1'b0;
    trap_cause = 4'b0000;
    
    if (exception_valid) begin
      trap_taken = 1'b1;
      trap_is_interrupt = selected_is_interrupt;
      trap_cause = selected_exception_code;
      
      // Select trap handler address based on mode
      if (selected_is_interrupt && (mtvec_mode == 1)) begin
        // Vectored mode for interrupts
        trap_handler_addr = mtvec_base + (selected_exception_code << 2);
      end else begin
        // Direct mode (all exceptions and synchronous interrupts)
        trap_handler_addr = mtvec_base;
      end
    end
  end
  
  // ============================================================================
  // Output Assignment
  // ============================================================================
  
  assign exception_valid = exc_valid_w;
  assign exception_code = selected_exception_code;
  assign exception_badaddr = selected_exception_badaddr;
  assign exception_pc = core_pc;                 // PC when exception occurred

endmodule : exception_handler

