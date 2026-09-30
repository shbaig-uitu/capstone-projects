// =============================================================
// page_table_ctrl.sv
// 32-entry, single-level page table.
// Lives entirely in registers inside this module (NOT memory-mapped
// as data memory -- programmed via a dedicated write port that the
// AXI4-Lite slave drives).
// Lookup is combinational (it's just a register-file read).
// =============================================================
import soc_pkg::*;

module page_table_ctrl (
  input  logic                   clk,
  input  logic                   rst_n,

  // Lookup port (combinational)
  input  logic [VPN_BITS-1:0]    lookup_vpn,
  output logic                   lookup_valid_o, // 1 = mapping exists
  output logic [PPN_BITS-1:0]    lookup_ppn_o,

  // Programming port (from AXI4-Lite regs)
  input  logic                   prog_en,
  input  logic [VPN_BITS-1:0]    prog_vpn,
  input  logic                   prog_valid_bit,
  input  logic [PPN_BITS-1:0]    prog_ppn
);

  logic                page_valid [NUM_VPAGES];
  logic [PPN_BITS-1:0] page_ppn   [NUM_VPAGES];

  // ---- combinational lookup --------------------------------------------
  assign lookup_valid_o = page_valid[lookup_vpn];
  assign lookup_ppn_o   = page_ppn[lookup_vpn];

  // ---- programming / reset ----------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < NUM_VPAGES; i++) begin
        page_valid[i] <= 1'b0;
        page_ppn[i]   <= '0;
      end
    end else if (prog_en) begin
      page_valid[prog_vpn] <= prog_valid_bit;
      page_ppn[prog_vpn]   <= prog_ppn;
    end
  end

endmodule
