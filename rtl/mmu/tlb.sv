/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: tlb.sv
 * Description: Complete Translation Lookaside Buffer (TLB)
 *              16 fully-associative entries with CAM logic
 *              Content-addressable memory for fast lookups
 */

`include "../include/riscv_defines.sv"
`include "../include/riscv_types.sv"

module tlb (
  input  logic                    clk,
  input  logic                    rst_n,
  
  // Read Port 0 - Instruction
  input  logic [`ADDR_WIDTH-1:0]  inst_vaddr,
  output logic [`ADDR_WIDTH-1:0]  inst_paddr,
  output logic                    inst_hit,
  
  // Read Port 1 - Data
  input  logic [`ADDR_WIDTH-1:0]  data_vaddr,
  output logic [`ADDR_WIDTH-1:0]  data_paddr,
  output logic                    data_hit,
  
  // Write Port
  input  logic                    write_en,
  input  logic [`ADDR_WIDTH-1:0]  write_vaddr,
  input  logic [`ADDR_WIDTH-1:0]  write_paddr,
  input  logic [7:0]              write_flags,  // V, R, W, X, U, G, A, D
  
  // Flush Interface
  input  logic                    flush_en,
  input  logic                    flush_all,    // 1=flush all, 0=flush one entry
  input  logic [`ADDR_WIDTH-1:0]  flush_vaddr,
  
  // Debug/Monitor
  output logic [31:0]             debug_hits,
  output logic [31:0]             debug_misses,
  output logic [3:0]              debug_valid_entries
);

  // ============================================================================
  // TLB Entry Structure
  // ============================================================================
  
  typedef struct packed {
    logic [19:0]  vpn;         // Virtual page number (upper 20 bits of VA)
    logic [19:0]  ppn;         // Physical page number
    logic         valid;
    logic         dirty;
    logic         accessed;
    logic         user_mode;
    logic         write_en;
    logic         exec_en;
    logic         read_en;
    logic         global;
  } tlb_entry_t;

  // ============================================================================
  // TLB Storage - 16 Fully Associative Entries (using individual arrays)
  // ============================================================================
  
  logic [19:0]  tlb_vpn [0:`TLB_ENTRIES-1];      // Virtual page number
  logic [19:0]  tlb_ppn [0:`TLB_ENTRIES-1];      // Physical page number
  logic         tlb_valid [0:`TLB_ENTRIES-1];
  logic         tlb_dirty [0:`TLB_ENTRIES-1];
  logic         tlb_accessed [0:`TLB_ENTRIES-1];
  logic         tlb_user [0:`TLB_ENTRIES-1];
  logic         tlb_write [0:`TLB_ENTRIES-1];
  logic         tlb_exec [0:`TLB_ENTRIES-1];
  logic         tlb_read [0:`TLB_ENTRIES-1];
  logic         tlb_global [0:`TLB_ENTRIES-1];
  
  logic [`TLB_INDEX_WIDTH-1:0] write_index;
  logic [`TLB_INDEX_WIDTH-1:0] replace_index;

  // ============================================================================
  // Hit Detection Logic (Content-Addressable Memory Style)
  // ============================================================================
  
  // Instruction lookup
  logic [15:0]  inst_hit_vec;
  logic         inst_match;
  
  always_comb begin
    for (int i = 0; i < `TLB_ENTRIES; i = i + 1) begin
      inst_hit_vec[i] = tlb_valid[i] && (tlb_vpn[i] == inst_vaddr[31:12]);
    end
  end
  
  // Find first hit entry (priority encoder)
  always_comb begin
    inst_match = 1'b0;
    inst_paddr = '0;
    for (int i = `TLB_ENTRIES-1; i >= 0; i = i - 1) begin
      if (inst_hit_vec[i]) begin
        inst_match = 1'b1;
        inst_paddr = {tlb_ppn[i], inst_vaddr[11:0]};
      end
    end
  end
  
  assign inst_hit = inst_match;

  // Data lookup
  logic [15:0]  data_hit_vec;
  logic         data_match;
  
  always_comb begin
    for (int i = 0; i < `TLB_ENTRIES; i = i + 1) begin
      data_hit_vec[i] = tlb_valid[i] && (tlb_vpn[i] == data_vaddr[31:12]);
    end
  end
  
  // Find first hit entry (priority encoder)
  always_comb begin
    data_match = 1'b0;
    data_paddr = '0;
    for (int i = `TLB_ENTRIES-1; i >= 0; i = i - 1) begin
      if (data_hit_vec[i]) begin
        data_match = 1'b1;
        data_paddr = {tlb_ppn[i], data_vaddr[11:0]};
      end
    end
  end
  
  assign data_hit = data_match;

  // ============================================================================
  // Replacement Policy - Simple Round-Robin
  // ============================================================================
  
  logic [`TLB_INDEX_WIDTH-1:0] rr_pointer = 0;
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rr_pointer <= '0;
    end else if (write_en) begin
      rr_pointer <= rr_pointer + 1;
    end
  end
  
  assign replace_index = rr_pointer;

  // ============================================================================
  // TLB Write and Update Logic
  // ============================================================================
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < `TLB_ENTRIES; i = i + 1) begin
        tlb_valid[i] <= 1'b0;
        tlb_vpn[i] <= '0;
        tlb_ppn[i] <= '0;
        tlb_dirty[i] <= 1'b0;
        tlb_accessed[i] <= 1'b0;
        tlb_user[i] <= 1'b0;
        tlb_write[i] <= 1'b0;
        tlb_exec[i] <= 1'b0;
        tlb_read[i] <= 1'b0;
        tlb_global[i] <= 1'b0;
      end
    end else begin
      
      // ========== FLUSH OPERATIONS ==========
      if (flush_all) begin
        // Flush all entries
        for (int i = 0; i < `TLB_ENTRIES; i = i + 1) begin
          tlb_valid[i] <= 1'b0;
        end
      end else if (flush_en) begin
        // Flush specific entry (search and invalidate)
        for (int i = 0; i < `TLB_ENTRIES; i = i + 1) begin
          if (tlb_vpn[i] == flush_vaddr[31:12]) begin
            tlb_valid[i] <= 1'b0;
          end
        end
      end
      
      // ========== WRITE OPERATIONS ==========
      if (write_en) begin
        tlb_valid[replace_index]    <= write_flags[0];           // V bit
        tlb_vpn[replace_index]      <= write_vaddr[31:12];
        tlb_ppn[replace_index]      <= write_paddr[31:12];
        tlb_read[replace_index]     <= write_flags[1];           // R bit
        tlb_write[replace_index]    <= write_flags[2];           // W bit
        tlb_exec[replace_index]     <= write_flags[3];           // X bit
        tlb_user[replace_index]     <= write_flags[4];           // U bit
        tlb_global[replace_index]   <= write_flags[5];           // G bit
        tlb_accessed[replace_index] <= write_flags[6];           // A bit
        tlb_dirty[replace_index]    <= write_flags[7];           // D bit
      end
    end
  end

  // ============================================================================
  // Statistics Counters
  // ============================================================================
  
  logic [31:0] hit_count = 0;
  logic [31:0] miss_count = 0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hit_count <= '0;
      miss_count <= '0;
    end else begin
      if (inst_hit || data_hit) begin
        hit_count <= hit_count + 1;
      end else if ((inst_vaddr != '0) || (data_vaddr != '0)) begin
        miss_count <= miss_count + 1;
      end
    end
  end

  assign debug_hits = hit_count;
  assign debug_misses = miss_count;

  // ============================================================================
  // Count Valid Entries
  // ============================================================================
  
  always_comb begin
    debug_valid_entries = 4'b0;
    for (int i = 0; i < `TLB_ENTRIES; i = i + 1) begin
      if (tlb_valid[i]) begin
        debug_valid_entries = debug_valid_entries + 1;
      end
    end
  end

endmodule
