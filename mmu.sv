// =============================================================
// mmu.sv
// Simplified MMU for DATA accesses only (instruction fetch bypasses
// this entirely - see docs/architecture.md, Section 1).
//
// Timing model:
//   TLB hit         -> translation + memory access complete in 1 cycle
//   TLB miss, valid -> +1 cycle to consult the page table & fill the TLB,
//                       memory access completes on that 2nd cycle
//   TLB miss, fault -> +1 cycle to discover it's unmapped, no memory
//                       access performed, fault status is latched
// =============================================================
import soc_pkg::*;

module mmu (
  input  logic                  clk,
  input  logic                  rst_n,

  // ---- core-facing (virtual) side --------------------------------------
  input  logic [VA_WIDTH-1:0]   va,
  input  logic                  mem_re,     // held high by core until ready
  input  logic                  mem_we,     // held high by core until ready
  input  logic [31:0]           wdata,
  output logic [31:0]           rdata,
  output logic                  ready,      // 1-cycle pulse: access complete

  // ---- physical data memory side ----------------------------------------
  output logic [PA_WIDTH-1:0]   pmem_addr,
  output logic                  pmem_we,
  output logic [31:0]           pmem_wdata,
  input  logic [31:0]           pmem_rdata,

  // ---- page-table programming pass-through (from AXI4-Lite regs) --------
  input  logic                  prog_en,
  input  logic [VPN_BITS-1:0]   prog_vpn,
  input  logic                  prog_valid_bit,
  input  logic [PPN_BITS-1:0]   prog_ppn,

  // ---- status (latched, cleared by AXI write; also live pulses) --------
  output logic                  fault_pulse_o,     // 1-cycle pulse on a fresh fault
  output logic                  hit_pulse_o,       // 1-cycle pulse on a TLB hit
  output logic                  miss_pulse_o,      // 1-cycle pulse on a TLB miss (valid or fault)
  input  logic                  status_clear,      // clears sticky fault latch
  output logic                  fault_latched_o
);

  // ---- split incoming VA -------------------------------------------------
  logic [VPN_BITS-1:0]   va_vpn;
  logic [PAGE_BITS-1:0]  va_off;
  assign va_vpn = va[VA_WIDTH-1 -: VPN_BITS];
  assign va_off = va[PAGE_BITS-1:0];

  // ---- TLB instance --------------------------------------------------
  logic                 tlb_hit;
  logic [PPN_BITS-1:0]  tlb_ppn;
  logic                 tlb_fill_en;
  logic [VPN_BITS-1:0]  tlb_fill_vpn;
  logic [PPN_BITS-1:0]  tlb_fill_ppn;
  logic [TLB_ENTRIES-1:0] tlb_valid_dbg;
  logic [TLB_IDX_BITS-1:0] tlb_repl_ptr_dbg;

  logic                 req;
  assign req = mem_re | mem_we;

  tlb u_tlb (
    .clk          (clk),
    .rst_n        (rst_n),
    .lookup_vpn   (va_vpn),
    .lookup_valid (req),
    .hit          (tlb_hit),
    .hit_ppn      (tlb_ppn),
    .fill_en      (tlb_fill_en),
    .fill_vpn     (tlb_fill_vpn),
    .fill_ppn     (tlb_fill_ppn),
    .flush        (1'b0),
    .entry_valid_o(tlb_valid_dbg),
    .repl_ptr_o   (tlb_repl_ptr_dbg)
  );

  // ---- page table instance -----------------------------------------------
  logic                 pt_valid;
  logic [PPN_BITS-1:0]  pt_ppn;
  logic [VPN_BITS-1:0]  pt_lookup_vpn;

  page_table_ctrl u_pt (
    .clk            (clk),
    .rst_n          (rst_n),
    .lookup_vpn     (pt_lookup_vpn),
    .lookup_valid_o (pt_valid),
    .lookup_ppn_o   (pt_ppn),
    .prog_en        (prog_en),
    .prog_vpn       (prog_vpn),
    .prog_valid_bit (prog_valid_bit),
    .prog_ppn       (prog_ppn)
  );

  // ---- FSM ----------------------------------------------------------------
  typedef enum logic [0:0] {S_IDLE, S_MISS} state_t;
  state_t state, state_n;

  logic [VPN_BITS-1:0]  lat_vpn;
  logic [PAGE_BITS-1:0] lat_off;
  logic                 lat_we;
  logic [31:0]          lat_wdata;

  assign pt_lookup_vpn = lat_vpn;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= S_IDLE;
    else        state <= state_n;
  end

  always_ff @(posedge clk) begin
    if (state == S_IDLE && req && !tlb_hit) begin
      lat_vpn   <= va_vpn;
      lat_off   <= va_off;
      lat_we    <= mem_we;
      lat_wdata <= wdata;
    end
  end

  always_comb begin
    // defaults
    state_n        = state;
    ready           = 1'b0;
    rdata           = 32'h0;
    pmem_addr       = '0;
    pmem_we         = 1'b0;
    pmem_wdata      = wdata;
    tlb_fill_en     = 1'b0;
    tlb_fill_vpn    = va_vpn;
    tlb_fill_ppn    = '0;
    fault_pulse_o   = 1'b0;
    hit_pulse_o     = 1'b0;
    miss_pulse_o    = 1'b0;

    case (state)
      S_IDLE: begin
        if (req) begin
          if (tlb_hit) begin
            // -------- fast path: translation + access in 1 cycle -------
            pmem_addr  = {tlb_ppn, va_off};
            pmem_we    = mem_we;
            pmem_wdata = wdata;
            rdata      = pmem_rdata;
            ready      = 1'b1;
            hit_pulse_o= 1'b1;
            state_n    = S_IDLE;
          end else begin
            // -------- slow path: need a page-table lookup ---------------
            miss_pulse_o = 1'b1;
            ready        = 1'b0;
            state_n      = S_MISS;
          end
        end
      end

      S_MISS: begin
        // pt_lookup_vpn == lat_vpn (latched last cycle), pt_valid/pt_ppn
        // are combinational off that.
        if (pt_valid) begin
          tlb_fill_en  = 1'b1;
          tlb_fill_vpn = lat_vpn;
          tlb_fill_ppn = pt_ppn;

          pmem_addr  = {pt_ppn, lat_off};
          pmem_we    = lat_we;
          pmem_wdata = lat_wdata;
          rdata      = pmem_rdata;
          ready      = 1'b1;
        end else begin
          // unmapped virtual page -> page fault
          fault_pulse_o = 1'b1;
          rdata         = FAULT_PATTERN;
          ready         = 1'b1;
          // no physical memory access performed
        end
        state_n = S_IDLE;
      end
    endcase
  end

  // ---- sticky fault status, cleared by AXI write ------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)              fault_latched_o <= 1'b0;
    else if (status_clear)   fault_latched_o <= 1'b0;
    else if (fault_pulse_o)  fault_latched_o <= 1'b1;
  end

endmodule
