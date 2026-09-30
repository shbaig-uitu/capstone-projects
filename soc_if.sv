interface soc_if #(parameter int CLK_FREQ_HZ = 100_000_000, parameter int BAUD_RATE = 115200)(input logic clk);
  logic rst_n, core_rst_n;
  logic [7:0] axi_awaddr; logic axi_awvalid, axi_awready;
  logic [31:0] axi_wdata; logic axi_wvalid, axi_wready;
  logic [1:0] axi_bresp; logic axi_bvalid, axi_bready;
  logic [7:0] axi_araddr; logic axi_arvalid, axi_arready;
  logic [31:0] axi_rdata; logic [1:0] axi_rresp; logic axi_rvalid, axi_rready;
  logic led_fault, led_hit, led_miss, uart_txd;

  // Internal observation points used by the passive MMU monitor.
  logic [12:0] dmem_va; logic dmem_re, dmem_we;
  logic [31:0] dmem_wdata, dmem_rdata; logic dmem_ready;
  logic [11:0] pmem_addr; logic pmem_we; logic [31:0] pmem_wdata, pmem_rdata;
  logic fault_pulse, hit_pulse, miss_pulse, fault_latched;
endinterface
