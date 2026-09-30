// =============================================================
// tlb.sv
// 4-entry, fully-associative TLB.
// Combinational lookup (hit/miss known same cycle it's asked).
// Fill happens synchronously, round-robin replacement.
// =============================================================
import soc_pkg::*;

module tlb (
  input  logic                    clk,
  input  logic                    rst_n,

  // Lookup port (combinational)
  input  logic [VPN_BITS-1:0]     lookup_vpn,
  input  logic                    lookup_valid,   // 1 = a translation is being requested this cycle
  output logic                    hit,
  output logic [PPN_BITS-1:0]     hit_ppn,

  // Fill port (synchronous) - called by MMU after a page-table lookup
  input  logic                    fill_en,
  input  logic [VPN_BITS-1:0]     fill_vpn,
  input  logic [PPN_BITS-1:0]     fill_ppn,

  // Flush (used on reset / explicit invalidate from AXI, optional)
  input  logic                    flush,

  // Debug/status
  output logic [TLB_ENTRIES-1:0]  entry_valid_o,
  output logic [TLB_IDX_BITS-1:0] repl_ptr_o
);

  logic                  v   [TLB_ENTRIES];
  logic [VPN_BITS-1:0]   vpn [TLB_ENTRIES];
  logic [PPN_BITS-1:0]   ppn [TLB_ENTRIES];

  logic [TLB_IDX_BITS-1:0] repl_ptr; // round-robin fill pointer

  // ---- combinational lookup -------------------------------------------
  logic [TLB_ENTRIES-1:0] match;
  always_comb begin
    for (int i = 0; i < TLB_ENTRIES; i++) begin
      match[i] = v[i] && (vpn[i] == lookup_vpn);
    end
  end

  always_comb begin
    hit     = 1'b0;
    hit_ppn = '0;
    if (lookup_valid) begin
      for (int i = 0; i < TLB_ENTRIES; i++) begin
        if (match[i]) begin
          hit     = 1'b1;
          hit_ppn = ppn[i];
        end
      end
    end
  end

  // ---- synchronous fill / flush / reset --------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < TLB_ENTRIES; i++) v[i] <= 1'b0;
      repl_ptr <= '0;
    end else if (flush) begin
      for (int i = 0; i < TLB_ENTRIES; i++) v[i] <= 1'b0;
      repl_ptr <= '0;
    end else if (fill_en) begin
      v[repl_ptr]   <= 1'b1;
      vpn[repl_ptr] <= fill_vpn;
      ppn[repl_ptr] <= fill_ppn;
      repl_ptr      <= repl_ptr + 1'b1; // round-robin
    end
  end

  always_comb begin
    for (int i = 0; i < TLB_ENTRIES; i++) entry_valid_o[i] = v[i];
  end
  assign repl_ptr_o = repl_ptr;

endmodule
