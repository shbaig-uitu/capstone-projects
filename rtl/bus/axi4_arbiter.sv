/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: axi4_arbiter.sv
 * Description: AXI4-Lite Bus Arbiter
 *              Arbitrates access between instruction and data memory requests
 *              to a single AXI4-Lite slave (external memory).
 *              Uses fixed priority: Instruction fetch > Data access
 */

`include "../include/riscv_defines.sv"
`include "../include/riscv_types.sv"

module axi4_arbiter (
  input  logic                clk,
  input  logic                rst_n,
  
  // ============================================================================
  // Instruction Memory Master (from MMU)
  // ============================================================================
  
  // Write Address Channel (not used for instruction fetch)
  input  logic [`AXI_ADDR_WIDTH-1:0]   inst_awaddr,
  input  logic [2:0]                   inst_awprot,
  input  logic                         inst_awvalid,
  output logic                         inst_awready,
  
  // Write Data Channel (not used for instruction fetch)
  input  logic [`AXI_DATA_WIDTH-1:0]   inst_wdata,
  input  logic [`AXI_STRB_WIDTH-1:0]   inst_wstrb,
  input  logic                         inst_wvalid,
  output logic                         inst_wready,
  
  // Write Response Channel
  output logic [1:0]                   inst_bresp,
  output logic                         inst_bvalid,
  input  logic                         inst_bready,
  
  // Read Address Channel
  input  logic [`AXI_ADDR_WIDTH-1:0]   inst_araddr,
  input  logic [2:0]                   inst_arprot,
  input  logic                         inst_arvalid,
  output logic                         inst_arready,
  
  // Read Data Channel
  output logic [`AXI_DATA_WIDTH-1:0]   inst_rdata,
  output logic [1:0]                   inst_rresp,
  output logic                         inst_rvalid,
  input  logic                         inst_rready,
  
  // ============================================================================
  // Data Memory Master (from MMU)
  // ============================================================================
  
  // Write Address Channel
  input  logic [`AXI_ADDR_WIDTH-1:0]   data_awaddr,
  input  logic [2:0]                   data_awprot,
  input  logic                         data_awvalid,
  output logic                         data_awready,
  
  // Write Data Channel
  input  logic [`AXI_DATA_WIDTH-1:0]   data_wdata,
  input  logic [`AXI_STRB_WIDTH-1:0]   data_wstrb,
  input  logic                         data_wvalid,
  output logic                         data_wready,
  
  // Write Response Channel
  output logic [1:0]                   data_bresp,
  output logic                         data_bvalid,
  input  logic                         data_bready,
  
  // Read Address Channel
  input  logic [`AXI_ADDR_WIDTH-1:0]   data_araddr,
  input  logic [2:0]                   data_arprot,
  input  logic                         data_arvalid,
  output logic                         data_arready,
  
  // Read Data Channel
  output logic [`AXI_DATA_WIDTH-1:0]   data_rdata,
  output logic [1:0]                   data_rresp,
  output logic                         data_rvalid,
  input  logic                         data_rready,
  
  // ============================================================================
  // AXI4-Lite Slave Interface (to external memory)
  // ============================================================================
  
  // Write Address Channel
  output logic [`AXI_ADDR_WIDTH-1:0]   s_awaddr,
  output logic [2:0]                   s_awprot,
  output logic                         s_awvalid,
  input  logic                         s_awready,
  
  // Write Data Channel
  output logic [`AXI_DATA_WIDTH-1:0]   s_wdata,
  output logic [`AXI_STRB_WIDTH-1:0]   s_wstrb,
  output logic                         s_wvalid,
  input  logic                         s_wready,
  
  // Write Response Channel
  input  logic [1:0]                   s_bresp,
  input  logic                         s_bvalid,
  output logic                         s_bready,
  
  // Read Address Channel
  output logic [`AXI_ADDR_WIDTH-1:0]   s_araddr,
  output logic [2:0]                   s_arprot,
  output logic                         s_arvalid,
  input  logic                         s_arready,
  
  // Read Data Channel
  input  logic [`AXI_DATA_WIDTH-1:0]   s_rdata,
  input  logic [1:0]                   s_rresp,
  input  logic                         s_rvalid,
  output logic                         s_rready
);

  // ============================================================================
  // Arbitration Logic - Fixed Priority
  // ============================================================================
  // Priority: Instruction > Data
  // This is a simple fixed-priority arbiter. In a more sophisticated design,
  // weighted round-robin or dynamic priority could be used.
  
  // ============================================================================
  // Read Address Channel Arbitration
  // ============================================================================
  
  logic ar_select_inst;  // 1 = select instruction, 0 = select data
  
  always_comb begin
    // Instruction has higher priority
    if (inst_arvalid) begin
      ar_select_inst = 1'b1;
    end else begin
      ar_select_inst = 1'b0;
    end
  end
  
  // Arbitrate AR channel to slave
  assign s_araddr  = ar_select_inst ? inst_araddr : data_araddr;
  assign s_arprot  = ar_select_inst ? inst_arprot : data_arprot;
  assign s_arvalid = ar_select_inst ? inst_arvalid : data_arvalid;
  
  // Distribute slave AR ready signal
  assign inst_arready = ar_select_inst ? s_arready : 1'b0;
  assign data_arready = ar_select_inst ? 1'b0 : s_arready;
  
  // ============================================================================
  // Read Data Channel - Direct passthrough (slave can only serve one at a time)
  // ============================================================================
  // The read data comes back from the slave. We need to route it to the
  // appropriate master based on which one had the read request in flight.
  
  logic r_select_inst;  // Track which master's read is currently being served
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      r_select_inst <= 1'b0;
    end else begin
      // On AR handshake, latch which master is being served
      if (s_arvalid && s_arready) begin
        r_select_inst <= ar_select_inst;
      end
    end
  end
  
  // Route read data to appropriate master
  assign inst_rdata  = s_rdata;
  assign inst_rresp  = s_rresp;
  assign inst_rvalid = r_select_inst ? s_rvalid : 1'b0;
  
  assign data_rdata  = s_rdata;
  assign data_rresp  = s_rresp;
  assign data_rvalid = r_select_inst ? 1'b0 : s_rvalid;
  
  // Route R ready signal back to slave (from whichever master is reading)
  assign s_rready = r_select_inst ? inst_rready : data_rready;
  
  // ============================================================================
  // Write Address Channel Arbitration
  // ============================================================================
  
  logic aw_select_inst;  // 1 = select instruction, 0 = select data
  
  always_comb begin
    // Instruction has higher priority (though instruction typically doesn't write)
    if (inst_awvalid) begin
      aw_select_inst = 1'b1;
    end else begin
      aw_select_inst = 1'b0;
    end
  end
  
  // Arbitrate AW channel to slave
  assign s_awaddr  = aw_select_inst ? inst_awaddr : data_awaddr;
  assign s_awprot  = aw_select_inst ? inst_awprot : data_awprot;
  assign s_awvalid = aw_select_inst ? inst_awvalid : data_awvalid;
  
  // Distribute slave AW ready signal
  assign inst_awready = aw_select_inst ? s_awready : 1'b0;
  assign data_awready = aw_select_inst ? 1'b0 : s_awready;
  
  // ============================================================================
  // Write Data Channel Arbitration
  // ============================================================================
  
  logic w_select_inst;  // 1 = select instruction, 0 = select data
  
  always_comb begin
    // Instruction has higher priority
    if (inst_wvalid) begin
      w_select_inst = 1'b1;
    end else begin
      w_select_inst = 1'b0;
    end
  end
  
  // Arbitrate W channel to slave
  assign s_wdata  = w_select_inst ? inst_wdata : data_wdata;
  assign s_wstrb  = w_select_inst ? inst_wstrb : data_wstrb;
  assign s_wvalid = w_select_inst ? inst_wvalid : data_wvalid;
  
  // Distribute slave W ready signal
  assign inst_wready = w_select_inst ? s_wready : 1'b0;
  assign data_wready = w_select_inst ? 1'b0 : s_wready;
  
  // ============================================================================
  // Write Response Channel - Direct passthrough
  // ============================================================================
  // Similar to read data, responses need to be routed back to correct master.
  
  logic b_select_inst;  // Track which master's write is being responded to
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      b_select_inst <= 1'b0;
    end else begin
      // On AW handshake, latch which master is being served
      if (s_awvalid && s_awready) begin
        b_select_inst <= aw_select_inst;
      end
    end
  end
  
  // Route write response to appropriate master
  assign inst_bresp  = s_bresp;
  assign inst_bvalid = b_select_inst ? s_bvalid : 1'b0;
  
  assign data_bresp  = s_bresp;
  assign data_bvalid = b_select_inst ? 1'b0 : s_bvalid;
  
  // Route B ready signal back to slave
  assign s_bready = b_select_inst ? inst_bready : data_bready;

endmodule : axi4_arbiter

