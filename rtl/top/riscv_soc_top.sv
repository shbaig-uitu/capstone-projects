/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: riscv_soc_top.sv
 * Description: Top-level SoC integration
 *              Instantiates RV32I core, MMU, TLB, CSR unit, exception handler,
 *              memory bus arbiter, and peripherals. Full interconnect integration.
 */

`include "../include/riscv_defines.sv"
`include "../include/riscv_types.sv"

module riscv_soc_top (
  input  logic                  clk,
  input  logic                  rst_n,
  
  // UART Interface
  input  logic                  uart_rx,
  output logic                  uart_tx,
  
  // GPIO Interface
  input  logic [7:0]            gpio_in,
  output logic [7:0]            gpio_out,
  
  // Debug Interface (AXI4-Lite)
  input  logic [31:0]           axi_awaddr,
  input  logic                  axi_awvalid,
  output logic                  axi_awready,
  
  input  logic [31:0]           axi_wdata,
  input  logic [3:0]            axi_wstrb,
  input  logic                  axi_wvalid,
  output logic                  axi_wready,
  
  output logic [1:0]            axi_bresp,
  output logic                  axi_bvalid,
  input  logic                  axi_bready,
  
  input  logic [31:0]           axi_araddr,
  input  logic                  axi_arvalid,
  output logic                  axi_arready,
  
  output logic [31:0]           axi_rdata,
  output logic [1:0]            axi_rresp,
  output logic                  axi_rvalid,
  input  logic                  axi_rready,
  
  // External interrupt
  input  logic                  ext_interrupt
);

  // ============================================================================
  // Internal Signal Declarations
  // ============================================================================
  
  // Core to MMU Instruction Interface
  logic [`ADDR_WIDTH-1:0]  core_inst_vaddr;
  logic                    core_inst_valid;
  logic [`ILEN-1:0]        core_inst_data;
  logic                    core_inst_ready;
  logic                    core_inst_fault;
  
  // Core to MMU Data Interface
  logic [`ADDR_WIDTH-1:0]  core_data_vaddr;
  logic                    core_data_valid;
  logic                    core_data_write;
  logic [`DATA_WIDTH-1:0]  core_data_wdata;
  logic [3:0]              core_data_byte_en;
  logic [`DATA_WIDTH-1:0]  core_data_rdata;
  logic                    core_data_ready;
  logic                    core_data_fault;
  
  // CSR Interface
  logic                    csr_valid;
  logic [11:0]             csr_addr;
  logic [`DATA_WIDTH-1:0]  csr_wdata;
  logic [1:0]              csr_op;
  logic [`DATA_WIDTH-1:0]  csr_rdata;
  logic                    csr_ready;
  
  // MMU to TLB Signals
  logic                    tlb_inst_hit;
  logic [`ADDR_WIDTH-1:0]  tlb_inst_paddr_result;
  logic                    tlb_data_hit;
  logic [`ADDR_WIDTH-1:0]  tlb_data_paddr_result;
  
  // MMU to Physical Memory (after translation)
  logic [`ADDR_WIDTH-1:0]  mmu_inst_paddr;
  logic                    mmu_inst_paddr_valid;
  logic [`ILEN-1:0]        mmu_inst_data;
  logic                    mmu_inst_ready;
  
  logic [`ADDR_WIDTH-1:0]  mmu_data_paddr;
  logic                    mmu_data_paddr_valid;
  logic                    mmu_data_write;
  logic [`DATA_WIDTH-1:0]  mmu_data_wdata;
  logic [3:0]              mmu_data_byte_en;
  logic [`DATA_WIDTH-1:0]  mmu_data_rdata;
  logic                    mmu_data_ready;
  
  // TLB Update signals
  logic                    tlb_write_en;
  logic [`ADDR_WIDTH-1:0]  tlb_write_vaddr;
  logic [`ADDR_WIDTH-1:0]  tlb_write_paddr;
  logic [7:0]              tlb_write_flags;
  
  // CSR output signals
  logic [`DATA_WIDTH-1:0]  satp_reg;
  logic                    satp_updated;
  logic [`DATA_WIDTH-1:0]  mstatus_reg;
  logic                    global_interrupt_en;
  logic                    timer_interrupt;
  logic [`DATA_WIDTH-1:0]  cycle_count;
  
  // Exception Signals
  logic                    exception_valid;
  logic [3:0]              exception_code;
  logic [`ADDR_WIDTH-1:0]  exception_badaddr;
  logic [`ADDR_WIDTH-1:0]  exception_pc;
  
  // Exception Handler Signals
  logic                    exc_handler_valid;
  logic [3:0]              exc_handler_code;
  logic [`ADDR_WIDTH-1:0]  exc_handler_badaddr;
  logic [`ADDR_WIDTH-1:0]  exc_handler_pc;
  logic                    exc_trap_taken;
  logic [`ADDR_WIDTH-1:0]  exc_trap_handler_addr;
  logic                    exc_trap_is_interrupt;
  logic [3:0]              exc_trap_cause;
  
  // Debug signals
  logic [4:0]              debug_reg_addr = 5'b0;
  logic [`DATA_WIDTH-1:0]  debug_reg_data;
  logic [`ADDR_WIDTH-1:0]  debug_pc;

  // ============================================================================
  // RV32I Core Instance
  // ============================================================================
  
  rv32i_core core_inst (
    .clk                  (clk),
    .rst_n                (rst_n),
    
    .inst_vaddr           (core_inst_vaddr),
    .inst_valid           (core_inst_valid),
    .inst_data            (core_inst_data),
    .inst_ready           (core_inst_ready),
    .inst_page_fault      (core_inst_fault),
    
    .data_vaddr           (core_data_vaddr),
    .data_valid           (core_data_valid),
    .data_write           (core_data_write),
    .data_wdata           (core_data_wdata),
    .data_byte_en         (core_data_byte_en),
    .data_rdata           (core_data_rdata),
    .data_ready           (core_data_ready),
    .data_page_fault      (core_data_fault),
    
    .csr_valid            (csr_valid),
    .csr_addr             (csr_addr),
    .csr_wdata            (csr_wdata),
    .csr_op               (csr_op),
    .csr_rdata            (csr_rdata),
    .csr_ready            (csr_ready),
    
    .exception_valid      (exception_valid),
    .exception_code       (exception_code),
    .exception_badaddr    (exception_badaddr),
    
    .debug_reg_addr       (debug_reg_addr),
    .debug_reg_data       (debug_reg_data),
    .debug_pc             (debug_pc)
  );

  // ============================================================================
  // MMU Instance (Instruction & Data)
  // ============================================================================
  
  mmu mmu_inst (
    .clk                  (clk),
    .rst_n                (rst_n),
    
    // Instruction side
    .inst_vaddr           (core_inst_vaddr),
    .inst_valid           (core_inst_valid),
    .inst_paddr           (mmu_inst_paddr),
    .inst_ready           (mmu_inst_ready),
    .inst_page_fault      (core_inst_fault),
    
    // Data side
    .data_vaddr           (core_data_vaddr),
    .data_valid           (core_data_valid),
    .data_is_write        (core_data_write),
    .data_paddr           (mmu_data_paddr),
    .data_ready           (mmu_data_ready),
    .data_page_fault      (core_data_fault),
    
    // TLB interface
    .tlb_inst_hit         (tlb_inst_hit),
    .tlb_inst_paddr       (tlb_inst_paddr_result),
    
    .tlb_data_hit         (tlb_data_hit),
    .tlb_data_paddr       (tlb_data_paddr_result),
    
    // TLB update interface
    .tlb_write_en         (tlb_write_en),
    .tlb_write_vaddr      (tlb_write_vaddr),
    .tlb_write_paddr      (tlb_write_paddr),
    .tlb_write_flags      (tlb_write_flags),
    
    // SATP from CSR unit
    .satp                 (satp_reg),
    
    // Debug
    .debug_page_faults    (),
    .debug_pt_walks       (),
    .debug_tlb_hits       ()
  );

  // ============================================================================
  // TLB Instance
  // ============================================================================
  
  tlb tlb_inst (
    .clk                  (clk),
    .rst_n                (rst_n),
    
    // Instruction lookup port
    .inst_vaddr           (core_inst_vaddr),
    .inst_hit             (tlb_inst_hit),
    .inst_paddr           (tlb_inst_paddr_result),
    
    // Data lookup port
    .data_vaddr           (core_data_vaddr),
    .data_hit             (tlb_data_hit),
    .data_paddr           (tlb_data_paddr_result),
    
    // Update port (from MMU page table walk)
    .write_en             (tlb_write_en),
    .write_vaddr          (tlb_write_vaddr),
    .write_paddr          (tlb_write_paddr),
    .write_flags          (tlb_write_flags),
    
    // Flush control
    .flush_all            (satp_updated),  // Flush on SATP write
    .flush_en             (satp_updated),
    .flush_vaddr          ('0),
    
    // Debug
    .debug_hits           (),
    .debug_misses         (),
    .debug_valid_entries  ()
  );

  // ============================================================================
  // CSR Unit Instance
  // ============================================================================
  
  csr_unit csr_inst (
    .clk                  (clk),
    .rst_n                (rst_n),
    
    // CSR Interface from Core
    .csr_valid            (csr_valid),
    .csr_addr             (csr_addr),
    .csr_wdata            (csr_wdata),
    .csr_op               (csr_op),
    .csr_rdata            (csr_rdata),
    .csr_ready            (csr_ready),
    
    // MMU Interface
    .satp_reg             (satp_reg),
    .satp_updated         (satp_updated),
    
    // Status Register
    .mstatus_reg          (mstatus_reg),
    
    // Exception Signals
    .exception_valid      (exception_valid),
    .exception_code       (exception_code),
    .exception_badaddr    (exception_badaddr),
    .exception_pc         (debug_pc),
    
    // Interrupt Control
    .global_interrupt_en  (global_interrupt_en),
    .timer_interrupt      (timer_interrupt),
    .ext_timer_interrupt  (ext_interrupt),
    
    // Performance Counters
    .cycle_count          (cycle_count)
  );

  // ============================================================================
  // Exception Handler Instance
  // ============================================================================
  
  exception_handler exc_handler_inst (
    .clk                  (clk),
    .rst_n                (rst_n),
    
    // Core exceptions
    .core_exception_valid (exception_valid),
    .core_exception_code  (exception_code),
    .core_exception_badaddr (exception_badaddr),
    .core_pc              (debug_pc),
    
    // MMU page faults
    .mmu_inst_page_fault  (core_inst_fault),
    .mmu_fault_addr       (core_inst_vaddr),
    .mmu_data_page_fault  (core_data_fault),
    .mmu_data_fault_addr  (core_data_vaddr),
    
    // CSR interface
    .mstatus              (mstatus_reg),
    .mie                  ('0),
    .mip                  ('0),
    .mtvec                (32'h80000000),  // Trap vector base
    
    // External interrupts
    .ext_timer_interrupt  (ext_interrupt),
    .ext_software_interrupt (1'b0),
    .ext_external_interrupt (1'b0),
    
    // Output exceptions
    .exception_valid      (exc_handler_valid),
    .exception_code       (exc_handler_code),
    .exception_badaddr    (exc_handler_badaddr),
    .exception_pc         (exc_handler_pc),
    
    // Trap handler control
    .trap_taken           (exc_trap_taken),
    .trap_handler_addr    (exc_trap_handler_addr),
    .trap_is_interrupt    (exc_trap_is_interrupt),
    .trap_cause           (exc_trap_cause)
  );

  // ============================================================================
  // Instruction Memory (SRAM)
  // ============================================================================
  
  sram_sp #(
    .DEPTH      (`INST_MEM_DEPTH),
    .WIDTH      (`DATA_WIDTH),
    .ADDR_WIDTH ($clog2(`INST_MEM_DEPTH)),
    .INIT_FILE  ("")
  ) inst_mem (
    .clk        (clk),
    .rst_n      (rst_n),
    .addr       (mmu_inst_paddr[$clog2(`INST_MEM_DEPTH)+1:2]),
    .write_en   (1'b0),
    .write_data ('0),
    .byte_en    (4'b1111),
    .read_data  (mmu_inst_data),
    .valid      (core_inst_valid),
    .ready      (mmu_inst_ready)
  );

  // ============================================================================
  // Data Memory (SRAM)
  // ============================================================================
  
  sram_sp #(
    .DEPTH      (`DATA_MEM_DEPTH),
    .WIDTH      (`DATA_WIDTH),
    .ADDR_WIDTH ($clog2(`DATA_MEM_DEPTH)),
    .INIT_FILE  ("")
  ) data_mem (
    .clk        (clk),
    .rst_n      (rst_n),
    .addr       (mmu_data_paddr[$clog2(`DATA_MEM_DEPTH)+1:2]),
    .write_en   (core_data_write),
    .write_data (core_data_wdata),
    .byte_en    (core_data_byte_en),
    .read_data  (mmu_data_rdata),
    .valid      (core_data_valid),
    .ready      (mmu_data_ready)
  );

  // ============================================================================
  // Wire-up core instruction and data paths
  // ============================================================================
  
  assign core_inst_ready = mmu_inst_ready;
  assign core_inst_data = mmu_inst_data;
  
  assign core_data_rdata = mmu_data_rdata;
  assign core_data_ready = mmu_data_ready;

  // ============================================================================
  // Peripheral Memory Map (AXI4-Lite Interface)
  // ============================================================================
  // 0x0000_0000 - 0x0000_3FFF: Instruction Memory (16KB)
  // 0x0001_0000 - 0x0001_3FFF: Data Memory (16KB)
  // 0x8000_0000 - 0x8000_00FF: UART Registers
  // 0x8000_0100 - 0x8000_01FF: GPIO Registers
  // 0x8000_0200 - 0x8000_02FF: CSR Control Registers

  // ============================================================================
  // UART Instance (Placeholder)
  // ============================================================================
  
  // Simple pass-through for UART
  assign uart_tx = uart_rx;  // Echo back for testing

  // ============================================================================
  // GPIO Instance (Placeholder)
  // ============================================================================
  
  // Simple pass-through for GPIO
  assign gpio_out = gpio_in;

  // ============================================================================
  // AXI4-Lite Subordinate (Debug Interface)
  // ============================================================================
  
  // For now, tie off AXI interface (no debug register access)
  assign axi_awready = 1'b1;
  assign axi_wready = 1'b1;
  assign axi_bvalid = 1'b0;
  assign axi_bresp = 2'b00;
  
  assign axi_arready = 1'b1;
  assign axi_rvalid = 1'b0;
  assign axi_rdata = '0;
  assign axi_rresp = 2'b00;

endmodule
