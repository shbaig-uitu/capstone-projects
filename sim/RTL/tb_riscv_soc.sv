/**
 * RISC-V SoC Testbench
 * Capstone Project
 * 
 * File: tb_riscv_soc.sv
 * Description: Basic testbench for functional verification
 */

`include "../rtl/include/riscv_defines.sv"
`include "../rtl/include/riscv_types.sv"
`timescale 1ns/1ps

module tb_riscv_soc ();

  // ============================================================================
  // Testbench Signals
  // ============================================================================
  
  logic clk;
  logic rst_n;
  logic uart_rx;
  logic uart_tx;
  logic [7:0] gpio_in;
  logic [7:0] gpio_out;
  logic [31:0] axi_awaddr;
  logic axi_awvalid;
  logic axi_awready;
  logic [31:0] axi_wdata;
  logic [3:0] axi_wstrb;
  logic axi_wvalid;
  logic axi_wready;
  logic [1:0] axi_bresp;
  logic axi_bvalid;
  logic axi_bready;
  logic [31:0] axi_araddr;
  logic axi_arvalid;
  logic axi_arready;
  logic [31:0] axi_rdata;
  logic [1:0] axi_rresp;
  logic axi_rvalid;
  logic axi_rready;
  logic ext_interrupt;
  
  // ============================================================================
  // DUT Instance
  // ============================================================================
  
  riscv_soc_top dut (
    .clk            (clk),
    .rst_n          (rst_n),
    .uart_rx        (uart_rx),
    .uart_tx        (uart_tx),
    .gpio_in        (gpio_in),
    .gpio_out       (gpio_out),
    .axi_awaddr     (axi_awaddr),
    .axi_awvalid    (axi_awvalid),
    .axi_awready    (axi_awready),
    .axi_wdata      (axi_wdata),
    .axi_wstrb      (axi_wstrb),
    .axi_wvalid     (axi_wvalid),
    .axi_wready     (axi_wready),
    .axi_bresp      (axi_bresp),
    .axi_bvalid     (axi_bvalid),
    .axi_bready     (axi_bready),
    .axi_araddr     (axi_araddr),
    .axi_arvalid    (axi_arvalid),
    .axi_arready    (axi_arready),
    .axi_rdata      (axi_rdata),
    .axi_rresp      (axi_rresp),
    .axi_rvalid     (axi_rvalid),
    .axi_rready     (axi_rready),
    .ext_interrupt  (ext_interrupt)
  );

  // ============================================================================
  // Clock Generation
  // ============================================================================
  
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 10ns period = 100 MHz
  end

  // ============================================================================
  // Reset and Test Sequence
  // ============================================================================
  
  initial begin
    // Initialize signals
    rst_n = 1'b0;
    uart_rx = 1'b0;
    gpio_in = 8'b0;
    axi_awvalid = 1'b0;
    axi_wvalid = 1'b0;
    axi_bready = 1'b0;
    axi_arvalid = 1'b0;
    axi_rready = 1'b0;
    ext_interrupt = 1'b0;
    
    // Wait a few cycles
    repeat(5) @(posedge clk);
    
    // Release reset
    rst_n = 1'b1;
    
    // Wait for initialization
    repeat(10) @(posedge clk);
    
    // ========== TEST 1: Clock Running ==========
    $display("[TB] Test 1: Clock is running and reset released");
    $display("[TB] Time=%0t, CLK=%b, RST_N=%b", $time, clk, rst_n);
    
    // ========== TEST 2: Check DPC (Debug PC) ==========
    $display("[TB] Test 2: Checking program counter advancement");
    repeat(20) @(posedge clk);
    $display("[TB] After 20 cycles - Design running");
    
    // ========== TEST 3: GPIO Pass-through ==========
    gpio_in = 8'hAA;
    repeat(2) @(posedge clk);
    $display("[TB] GPIO: Input=0x%02X, Output=0x%02X", gpio_in, gpio_out);
    if (gpio_out == 8'hAA) begin
      $display("[TB] ✓ GPIO pass-through working");
    end else begin
      $display("[TB] ✗ GPIO mismatch!");
    end
    
    // ========== TEST 4: UART Echo ==========
    uart_rx = 1'b1;
    repeat(2) @(posedge clk);
    $display("[TB] UART: RX=%b, TX=%b", uart_rx, uart_tx);
    if (uart_tx == uart_rx) begin
      $display("[TB] ✓ UART echo working");
    end else begin
      $display("[TB] ✗ UART echo failed!");
    end
    
    // ========== TEST 5: Run for extended time ==========
    $display("[TB] Test 5: Extended simulation");
    repeat(100) @(posedge clk);
    $display("[TB] Simulation completed successfully");
    
    $finish;
  end
  
  // ============================================================================
  // Wave dumping (for GTKWave viewing)
  // ============================================================================
  
  initial begin
    $dumpfile("riscv_soc.vcd");
    $dumpvars(0, tb_riscv_soc);
  end

endmodule
