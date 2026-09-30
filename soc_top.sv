// =============================================================
// soc_top.sv
// Top-level RV32I SoC with simplified virtual memory.
//
//   core_rst_n : lets a host/testbench hold the RV32I core in reset
//                while it programs the page table over AXI4-Lite,
//                then release it to start running. rst_n resets
//                everything else (TLB, page table, AXI regs).
// =============================================================
import soc_pkg::*;

module soc_top #(
  parameter int CLK_FREQ_HZ       = 50_000_000,
  parameter int UART_BAUD         = 115_200,
  parameter int DEBUG_STRETCH_BITS = 20,
  parameter string IMEM_INIT_FILE = ""
) (
  input  logic clk,
  input  logic rst_n,       // global reset (TLB, page table, AXI regs)
  input  logic core_rst_n,  // gates the RV32I core specifically

  // ---- AXI4-Lite slave (host programs page table / reads status) --------
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

  // ---- debug outputs (FPGA LEDs + UART) ------------------------------------
  output logic led_fault,
  output logic led_hit,
  output logic led_miss,
  output logic uart_txd
);

  // ---- core <-> instruction memory ----------------------------------------
  logic [IMEM_ADDR_BITS-1:0] imem_addr;
  logic [31:0]               imem_rdata;

  // ---- core <-> MMU (virtual) ---------------------------------------------
  logic [VA_WIDTH-1:0] dmem_va;
  logic                dmem_re, dmem_we, dmem_ready;
  logic [31:0]         dmem_wdata, dmem_rdata;

  // ---- MMU <-> physical data memory ---------------------------------------
  logic [PA_WIDTH-1:0] pmem_addr;
  logic                 pmem_we;
  logic [31:0]          pmem_wdata, pmem_rdata;

  // ---- MMU <-> page table programming (from AXI) --------------------------
  logic                 prog_en;
  logic [VPN_BITS-1:0]  prog_vpn;
  logic                 prog_valid_bit;
  logic [PPN_BITS-1:0]  prog_ppn;

  // ---- MMU <-> AXI status ---------------------------------------------------
  logic fault_pulse, hit_pulse, miss_pulse, fault_latched, status_clear;
  logic [TLB_ENTRIES-1:0]  tlb_entry_valid;
  logic [TLB_IDX_BITS-1:0] tlb_repl_ptr;

  rv32i_core u_core (
    .clk        (clk),
    .rst_n      (core_rst_n),
    .imem_addr  (imem_addr),
    .imem_rdata (imem_rdata),
    .dmem_va    (dmem_va),
    .dmem_re    (dmem_re),
    .dmem_we    (dmem_we),
    .dmem_wdata (dmem_wdata),
    .dmem_rdata (dmem_rdata),
    .dmem_ready (dmem_ready)
  );

  instr_mem #(
    .INIT_FILE (IMEM_INIT_FILE)
  ) u_imem (
    .addr  (imem_addr),
    .rdata (imem_rdata)
  );

  data_mem u_dmem (
    .clk   (clk),
    .addr  (pmem_addr),
    .we    (pmem_we),
    .wdata (pmem_wdata),
    .rdata (pmem_rdata)
  );

  mmu u_mmu (
    .clk            (clk),
    .rst_n          (rst_n),
    .va             (dmem_va),
    .mem_re         (dmem_re),
    .mem_we         (dmem_we),
    .wdata          (dmem_wdata),
    .rdata          (dmem_rdata),
    .ready          (dmem_ready),
    .pmem_addr      (pmem_addr),
    .pmem_we        (pmem_we),
    .pmem_wdata     (pmem_wdata),
    .pmem_rdata     (pmem_rdata),
    .prog_en        (prog_en),
    .prog_vpn       (prog_vpn),
    .prog_valid_bit (prog_valid_bit),
    .prog_ppn       (prog_ppn),
    .fault_pulse_o  (fault_pulse),
    .hit_pulse_o    (hit_pulse),
    .miss_pulse_o   (miss_pulse),
    .status_clear   (status_clear),
    .fault_latched_o(fault_latched)
  );

  axi_lite_regs u_axi (
    .clk            (clk),
    .rst_n          (rst_n),
    .s_axi_awaddr   (s_axi_awaddr),
    .s_axi_awvalid  (s_axi_awvalid),
    .s_axi_awready  (s_axi_awready),
    .s_axi_wdata    (s_axi_wdata),
    .s_axi_wvalid   (s_axi_wvalid),
    .s_axi_wready   (s_axi_wready),
    .s_axi_bresp    (s_axi_bresp),
    .s_axi_bvalid   (s_axi_bvalid),
    .s_axi_bready   (s_axi_bready),
    .s_axi_araddr   (s_axi_araddr),
    .s_axi_arvalid  (s_axi_arvalid),
    .s_axi_arready  (s_axi_arready),
    .s_axi_rdata    (s_axi_rdata),
    .s_axi_rresp    (s_axi_rresp),
    .s_axi_rvalid   (s_axi_rvalid),
    .s_axi_rready   (s_axi_rready),
    .prog_en        (prog_en),
    .prog_vpn       (prog_vpn),
    .prog_valid_bit (prog_valid_bit),
    .prog_ppn       (prog_ppn),
    .status_clear   (status_clear),
    .fault_latched  (fault_latched),
    .tlb_entry_valid(tlb_entry_valid),
    .tlb_repl_ptr   (tlb_repl_ptr),
    .hit_pulse      (hit_pulse),
    .miss_pulse     (miss_pulse)
  );

  debug_io #(
    .STRETCH_BITS (DEBUG_STRETCH_BITS),
    .CLK_FREQ_HZ  (CLK_FREQ_HZ),
    .UART_BAUD    (UART_BAUD)
  ) u_debug (
    .clk           (clk),
    .rst_n         (rst_n),
    .fault_latched (fault_latched),
    .hit_pulse     (hit_pulse),
    .miss_pulse    (miss_pulse),
    .led_fault     (led_fault),
    .led_hit       (led_hit),
    .led_miss      (led_miss),
    .uart_txd      (uart_txd)
  );

  // tlb_entry_valid / tlb_repl_ptr are internal to u_mmu.u_tlb; expose them
  // for the AXI debug register via hierarchical reference (sim/synthesis
  // both support this for a project of this scope).
  assign tlb_entry_valid = u_mmu.tlb_valid_dbg;
  assign tlb_repl_ptr    = u_mmu.tlb_repl_ptr_dbg;

endmodule
