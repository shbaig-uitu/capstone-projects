// =============================================================
// axi_lite_regs.sv
// Simplified AXI4-Lite slave (single-beat, always-ready, no
// pipelining -- a standard classroom simplification of the full
// AXI4-Lite handshake). Used by an external host / testbench to
// program the page table before/while the core runs, and to read
// back fault + TLB status.
//
// Register map (offsets within 0x8000_0000 base):
//   0x00  PAGE_TABLE_PROG (write-only, commits on write)
//           bit0      = valid bit for the entry
//           bits4:1   = PPN
//           bits9:5   = VPN
//   0x04  FAULT_STATUS (read: bit0 = sticky page-fault flag)
//                       (write: any value clears the sticky flag)
//   0x08  TLB_DEBUG (read-only): {repl_ptr[1:0], entry_valid[3:0]}
//   0x0C  HIT_COUNT  (read-only, free-running TLB hit counter)
//   0x10  MISS_COUNT (read-only, free-running TLB miss counter)
// =============================================================
import soc_pkg::*;

module axi_lite_regs (
  input  logic        clk,
  input  logic        rst_n,

  // ---- AXI4-Lite slave port ------------------------------------------
  input  logic [7:0]  s_axi_awaddr,
  input  logic         s_axi_awvalid,
  output logic         s_axi_awready,
  input  logic [31:0]  s_axi_wdata,
  input  logic          s_axi_wvalid,
  output logic          s_axi_wready,
  output logic [1:0]    s_axi_bresp,
  output logic          s_axi_bvalid,
  input  logic          s_axi_bready,
  input  logic [7:0]    s_axi_araddr,
  input  logic          s_axi_arvalid,
  output logic          s_axi_arready,
  output logic [31:0]   s_axi_rdata,
  output logic [1:0]    s_axi_rresp,
  output logic          s_axi_rvalid,
  input  logic          s_axi_rready,

  // ---- to page_table_ctrl / mmu ------------------------------------------
  output logic                 prog_en,
  output logic [VPN_BITS-1:0]  prog_vpn,
  output logic                 prog_valid_bit,
  output logic [PPN_BITS-1:0]  prog_ppn,

  output logic                 status_clear,
  input  logic                 fault_latched,
  input  logic [TLB_ENTRIES-1:0] tlb_entry_valid,
  input  logic [TLB_IDX_BITS-1:0] tlb_repl_ptr,
  input  logic                    hit_pulse,
  input  logic                    miss_pulse
);

  // ---- write channel (single-beat) ---------------------------------------
  logic aw_hs, w_hs;
  assign s_axi_awready = !s_axi_bvalid; // simple: accept when not waiting on B
  assign s_axi_wready  = !s_axi_bvalid;
  assign aw_hs = s_axi_awvalid && s_axi_awready;
  assign w_hs  = s_axi_wvalid  && s_axi_wready;

  logic [7:0] awaddr_lat;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      s_axi_bvalid <= 1'b0;
      s_axi_bresp  <= 2'b00;
      awaddr_lat   <= 8'h0;
      prog_en        <= 1'b0;
      prog_vpn       <= '0;
      prog_valid_bit <= 1'b0;
      prog_ppn       <= '0;
      status_clear   <= 1'b0;
    end else begin
      prog_en      <= 1'b0;
      status_clear <= 1'b0;

      if (aw_hs) awaddr_lat <= s_axi_awaddr;

      if (w_hs) begin
        s_axi_bvalid <= 1'b1;
        s_axi_bresp  <= 2'b00; // OKAY
        case (aw_hs ? s_axi_awaddr : awaddr_lat)
          8'h00: begin
            prog_en        <= 1'b1;
            prog_valid_bit <= s_axi_wdata[0];
            prog_ppn       <= s_axi_wdata[4:1];
            prog_vpn       <= s_axi_wdata[9:5];
          end
          8'h04: status_clear <= 1'b1;
          default: ; // read-only regs ignore writes
        endcase
      end else if (s_axi_bvalid && s_axi_bready) begin
        s_axi_bvalid <= 1'b0;
      end
    end
  end

  // ---- read channel (single-beat) -----------------------------------------
  logic [31:0] hit_count, miss_count;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hit_count  <= 32'h0;
      miss_count <= 32'h0;
    end else begin
      if (hit_pulse)  hit_count  <= hit_count + 1'b1;
      if (miss_pulse) miss_count <= miss_count + 1'b1;
    end
  end

  assign s_axi_arready = !s_axi_rvalid;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      s_axi_rvalid <= 1'b0;
      s_axi_rresp  <= 2'b00;
      s_axi_rdata  <= 32'h0;
    end else begin
      if (s_axi_arvalid && s_axi_arready) begin
        s_axi_rvalid <= 1'b1;
        s_axi_rresp  <= 2'b00;
        case (s_axi_araddr)
          8'h04:   s_axi_rdata <= {31'h0, fault_latched};
          8'h08:   s_axi_rdata <= {26'h0, tlb_repl_ptr, tlb_entry_valid}; // {repl_ptr[1:0], entry_valid[3:0]}
          8'h0C:   s_axi_rdata <= hit_count;
          8'h10:   s_axi_rdata <= miss_count;
          default: s_axi_rdata <= 32'h0;
        endcase
      end else if (s_axi_rvalid && s_axi_rready) begin
        s_axi_rvalid <= 1'b0;
      end
    end
  end

endmodule
