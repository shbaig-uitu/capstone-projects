/**
 * RISC-V SoC UVM Testbench - Interface Definition
 * 
 * File: uvm_riscv_if.sv
 * Description: SystemVerilog interface for RISC-V SoC verification
 */

interface riscv_soc_if (
  input logic clk,
  input logic rst_n
);

  // ============================================================================
  // System Signals
  // ============================================================================
  
  logic                  clk;
  logic                  rst_n;
  
  // ============================================================================
  // UART Interface
  // ============================================================================
  
  logic                  uart_rx;
  logic                  uart_tx;
  
  // ============================================================================
  // GPIO Interface
  // ============================================================================
  
  logic [7:0]            gpio_in;
  logic [7:0]            gpio_out;
  
  // ============================================================================
  // Debug Interface (AXI4-Lite)
  // ============================================================================
  
  // Write Address Channel
  logic [31:0]           axi_awaddr;
  logic                  axi_awvalid;
  logic                  axi_awready;
  
  // Write Data Channel
  logic [31:0]           axi_wdata;
  logic [3:0]            axi_wstrb;
  logic                  axi_wvalid;
  logic                  axi_wready;
  
  // Write Response Channel
  logic [1:0]            axi_bresp;
  logic                  axi_bvalid;
  logic                  axi_bready;
  
  // Read Address Channel
  logic [31:0]           axi_araddr;
  logic                  axi_arvalid;
  logic                  axi_arready;
  
  // Read Data Channel
  logic [31:0]           axi_rdata;
  logic [1:0]            axi_rresp;
  logic                  axi_rvalid;
  logic                  axi_rready;
  
  // ============================================================================
  // External Interrupt
  // ============================================================================
  
  logic                  ext_interrupt;
  
  // ============================================================================
  // Modports for Driver and Monitor
  // ============================================================================
  
  modport driver (
    output uart_rx,
    output gpio_in,
    output axi_awaddr, axi_awvalid,
    output axi_wdata, axi_wstrb, axi_wvalid,
    output axi_bready,
    output axi_araddr, axi_arvalid,
    output axi_rready,
    output ext_interrupt,
    input  uart_tx,
    input  gpio_out,
    input  axi_awready,
    input  axi_wready,
    input  axi_bresp, axi_bvalid,
    input  axi_arready,
    input  axi_rdata, axi_rresp, axi_rvalid
  );
  
  modport monitor (
    input uart_rx, uart_tx,
    input gpio_in, gpio_out,
    input axi_awaddr, axi_awvalid, axi_awready,
    input axi_wdata, axi_wstrb, axi_wvalid, axi_wready,
    input axi_bresp, axi_bvalid, axi_bready,
    input axi_araddr, axi_arvalid, axi_arready,
    input axi_rdata, axi_rresp, axi_rvalid, axi_rready,
    input ext_interrupt
  );
  
  modport testbench (
    output uart_rx,
    output gpio_in,
    output axi_awaddr, axi_awvalid,
    output axi_wdata, axi_wstrb, axi_wvalid,
    output axi_bready,
    output axi_araddr, axi_arvalid,
    output axi_rready,
    output ext_interrupt,
    input  uart_tx,
    input  gpio_out,
    input  axi_awready,
    input  axi_wready,
    input  axi_bresp, axi_bvalid,
    input  axi_arready,
    input  axi_rdata, axi_rresp, axi_rvalid
  );
  
endinterface : riscv_soc_if
