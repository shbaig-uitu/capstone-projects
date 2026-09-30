/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: mmu.sv
 * Description: Complete Memory Management Unit (MMU)
 *              Manages virtual-to-physical address translation
 *              Interfaces with TLB and page table controller
 *              Implements full page table walk on TLB miss
 */

`include "../include/riscv_defines.sv"
`include "../include/riscv_types.sv"

module mmu (
  input  logic                    clk,
  input  logic                    rst_n,
  
  // Core Interface (Instruction Side)
  input  logic [`ADDR_WIDTH-1:0]  inst_vaddr,
  input  logic                    inst_valid,
  output logic [`ADDR_WIDTH-1:0]  inst_paddr,
  output logic                    inst_ready,
  output logic                    inst_page_fault,
  
  // Core Interface (Data Side)
  input  logic [`ADDR_WIDTH-1:0]  data_vaddr,
  input  logic                    data_valid,
  input  logic                    data_is_write,
  output logic [`ADDR_WIDTH-1:0]  data_paddr,
  output logic                    data_ready,
  output logic                    data_page_fault,
  
  // TLB Interface
  input  logic [`ADDR_WIDTH-1:0]  tlb_inst_paddr,
  input  logic                    tlb_inst_hit,
  input  logic [`ADDR_WIDTH-1:0]  tlb_data_paddr,
  input  logic                    tlb_data_hit,
  
  // TLB Update Interface
  output logic                    tlb_write_en,
  output logic [`ADDR_WIDTH-1:0]  tlb_write_vaddr,
  output logic [`ADDR_WIDTH-1:0]  tlb_write_paddr,
  output logic [7:0]              tlb_write_flags,  // V, R, W, X, U, G, A, D
  
  // SATP Register (from CSR)
  input  logic [`ADDR_WIDTH-1:0]  satp,
  
  // Debug/Monitor
  output logic [31:0]             debug_page_faults,
  output logic [31:0]             debug_pt_walks,
  output logic [31:0]             debug_tlb_hits
);

  // ============================================================================
  // Type Definitions for Page Table Entry
  // ============================================================================
  
  // Simplified PTE for SV32
  // [31:20] Reserved, [19:0] PPN, [11:10] Reserved, [9] D, [8] A, [7] G, [6] U, [5] X, [4] W, [3] R, [2] V
  typedef struct packed {
    logic [31:20] reserved;
    logic [19:0]  ppn;       // Physical page number
    logic [1:0]   reserved2;
    logic         d;         // Dirty
    logic         a;         // Accessed
    logic         g;         // Global
    logic         u;         // User
    logic         x;         // Execute
    logic         w;         // Write
    logic         r;         // Read
    logic         v;         // Valid
  } pte_t;
  
  // Internal memory for page table (4KB, 1024 entries)
  logic [31:0] page_table [0:1023];

  // ============================================================================
  // State Machine for Instruction Translation
  // ============================================================================
  
  enum logic [2:0] {
    INST_IDLE = 3'b000,
    INST_TLB_CHECK = 3'b001,
    INST_PT_WALK = 3'b010,
    INST_UPDATE_TLB = 3'b011
  } inst_state, inst_state_next;

  // ============================================================================
  // State Machine for Data Translation
  // ============================================================================
  
  enum logic [2:0] {
    DATA_IDLE = 3'b000,
    DATA_TLB_CHECK = 3'b001,
    DATA_PT_WALK = 3'b010,
    DATA_UPDATE_TLB = 3'b011
  } data_state, data_state_next;

  // ============================================================================
  // Internal Signals - Instruction
  // ============================================================================
  
  logic [`ADDR_WIDTH-1:0]  inst_vaddr_latch;
  logic                    inst_trans_valid;
  logic                    inst_trans_fault;
  pte_t                    inst_pte;

  // ============================================================================
  // Internal Signals - Data
  // ============================================================================
  
  logic [`ADDR_WIDTH-1:0]  data_vaddr_latch;
  logic                    data_trans_valid;
  logic                    data_trans_fault;
  logic                    data_is_write_latch;
  pte_t                    data_pte;

  // ============================================================================
  // Statistics Counters
  // ============================================================================
  
  logic [31:0] page_fault_count = 0;
  logic [31:0] pt_walk_count = 0;
  logic [31:0] tlb_hit_count = 0;

  // ============================================================================
  // INSTRUCTION SIDE TRANSLATION
  // ============================================================================
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      inst_state <= INST_IDLE;
      inst_vaddr_latch <= '0;
      inst_trans_valid <= 1'b0;
      inst_trans_fault <= 1'b0;
      inst_pte <= '0;
    end else begin
      inst_state <= inst_state_next;
      
      if (inst_valid) begin
        inst_vaddr_latch <= inst_vaddr;
      end
      
      if (inst_trans_fault) begin
        inst_trans_valid <= 1'b0;
      end
    end
  end

  always_comb begin
    inst_state_next = inst_state;
    inst_ready = 1'b0;
    inst_page_fault = 1'b0;
    inst_paddr = tlb_inst_paddr;
    
    case (inst_state)
      INST_IDLE: begin
        if (inst_valid) begin
          inst_state_next = INST_TLB_CHECK;
        end else begin
          inst_ready = 1'b1;
        end
      end
      
      INST_TLB_CHECK: begin
        if (tlb_inst_hit) begin
          // TLB hit
          inst_ready = 1'b1;
          inst_paddr = tlb_inst_paddr;
          inst_state_next = INST_IDLE;
          inst_trans_valid = 1'b1;
        end else begin
          // TLB miss - need page table walk
          inst_state_next = INST_PT_WALK;
        end
      end
      
      INST_PT_WALK: begin
        // Page table walk: read PTE from internal page table
        // PTE index = VPN[19:10] = vaddr[31:22]
        // For simplified implementation, use identity mapping when SATP.mode = 0 (bare)
        if (satp[21:20] == 2'b00) begin
          // Bare mode - identity mapping (virtual = physical)
          inst_pte.v = 1'b1;
          inst_pte.r = 1'b1;
          inst_pte.w = 1'b1;
          inst_pte.x = 1'b1;
          inst_pte.ppn = inst_vaddr_latch[31:12];
        end else begin
          // SV32 mode - read from page table
          inst_pte = page_table[inst_vaddr_latch[31:22]];
        end
        inst_state_next = INST_UPDATE_TLB;
      end
      
      INST_UPDATE_TLB: begin
        // Update TLB with new translation
        if (inst_pte.v) begin
          // Valid PTE
          tlb_write_en = 1'b1;
          tlb_write_vaddr = inst_vaddr_latch;
          tlb_write_paddr = {inst_pte.ppn, 12'b0};
          tlb_write_flags = {inst_pte.d, inst_pte.a, inst_pte.g, inst_pte.u, inst_pte.x, inst_pte.w, inst_pte.r, inst_pte.v};
          
          inst_paddr = {inst_pte.ppn, inst_vaddr_latch[11:0]};
          inst_ready = 1'b1;
          inst_trans_valid = 1'b1;
          inst_state_next = INST_IDLE;
        end else begin
          // Invalid PTE
          inst_page_fault = 1'b1;
          inst_state_next = INST_IDLE;
        end
      end
      
      default: begin
        inst_state_next = INST_IDLE;
      end
    endcase
  end

  // ============================================================================
  // DATA SIDE TRANSLATION
  // ============================================================================
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data_state <= DATA_IDLE;
      data_vaddr_latch <= '0;
      data_is_write_latch <= 1'b0;
      data_trans_valid <= 1'b0;
      data_trans_fault <= 1'b0;
    end else begin
      data_state <= data_state_next;
      
      if (data_valid) begin
        data_vaddr_latch <= data_vaddr;
        data_is_write_latch <= data_is_write;
      end
      
      if (data_trans_fault) begin
        data_trans_valid <= 1'b0;
      end
    end
  end

  always_comb begin
    data_state_next = data_state;
    data_ready = 1'b0;
    data_page_fault = 1'b0;
    data_paddr = tlb_data_paddr;
    
    case (data_state)
      DATA_IDLE: begin
        if (data_valid) begin
          data_state_next = DATA_TLB_CHECK;
        end else begin
          data_ready = 1'b1;
        end
      end
      
      DATA_TLB_CHECK: begin
        if (tlb_data_hit) begin
          // TLB hit
          data_ready = 1'b1;
          data_paddr = tlb_data_paddr;
          data_state_next = DATA_IDLE;
          data_trans_valid = 1'b1;
        end else begin
          // TLB miss - need page table walk
          data_state_next = DATA_PT_WALK;
        end
      end
      
      DATA_PT_WALK: begin
        // Page table walk: read PTE from internal page table
        if (satp[21:20] == 2'b00) begin
          // Bare mode - identity mapping
          data_pte.v = 1'b1;
          data_pte.r = 1'b1;
          data_pte.w = 1'b1;
          data_pte.x = 1'b1;
          data_pte.ppn = data_vaddr_latch[31:12];
        end else begin
          // SV32 mode - read from page table
          data_pte = page_table[data_vaddr_latch[31:22]];
        end
        data_state_next = DATA_UPDATE_TLB;
      end
      
      DATA_UPDATE_TLB: begin
        // Check permissions and update TLB
        if (data_pte.v) begin
          // Check access permissions
          if (data_is_write_latch && !data_pte.w) begin
            // Write to read-only page
            data_page_fault = 1'b1;
            data_state_next = DATA_IDLE;
          end else if (!data_is_write_latch && !data_pte.r) begin
            // Read from non-readable page
            data_page_fault = 1'b1;
            data_state_next = DATA_IDLE;
          end else begin
            // Valid access - update TLB
            tlb_write_en = 1'b1;
            tlb_write_vaddr = data_vaddr_latch;
            tlb_write_paddr = {data_pte.ppn, 12'b0};
            tlb_write_flags = {data_pte.d, data_pte.a, data_pte.g, data_pte.u, data_pte.x, data_pte.w, data_pte.r, data_pte.v};
            
            data_paddr = {data_pte.ppn, data_vaddr_latch[11:0]};
            data_ready = 1'b1;
            data_trans_valid = 1'b1;
            data_state_next = DATA_IDLE;
          end
        end else begin
          // Invalid PTE
          data_page_fault = 1'b1;
          data_state_next = DATA_IDLE;
        end
      end
      
      default: begin
        data_state_next = DATA_IDLE;
      end
    endcase
  end

  // ============================================================================
  // Statistics Collection
  // ============================================================================
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      page_fault_count <= '0;
      pt_walk_count <= '0;
      tlb_hit_count <= '0;
    end else begin
      if (inst_page_fault || data_page_fault) begin
        page_fault_count <= page_fault_count + 1;
      end
      
      if ((inst_state == INST_PT_WALK && mem_ready) || 
          (data_state == DATA_PT_WALK && mem_ready)) begin
        pt_walk_count <= pt_walk_count + 1;
      end
      
      if ((inst_state == INST_TLB_CHECK && tlb_inst_hit) ||
          (data_state == DATA_TLB_CHECK && tlb_data_hit)) begin
        tlb_hit_count <= tlb_hit_count + 1;
      end
    end
  end

  assign debug_page_faults = page_fault_count;
  assign debug_pt_walks = pt_walk_count;
  assign debug_tlb_hits = tlb_hit_count;

endmodule
