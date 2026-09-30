/**
 * RISC-V SoC UVM Top-Level Testbench
 * 
 * File: tb_riscv_uvm.sv
 * Description: Top-level UVM testbench instantiating DUT and interface
 */

`timescale 1ns/1ps

`include "uvm_macros.svh"

module tb_riscv_uvm;
  import uvm_pkg::*;
  import riscv_uvm_pkg::*;
  
  // ============================================================================
  // Clock and Reset
  // ============================================================================
  
  logic clk;
  logic rst_n;
  
  // ============================================================================
  // Clock Generation (100 MHz)
  // ============================================================================
  
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 10ns period = 100 MHz
  end
  
  // ============================================================================
  // Reset Sequence
  // ============================================================================
  
  initial begin
    rst_n = 1'b0;
    repeat(10) @(posedge clk);  // Hold reset for 10 cycles
    rst_n = 1'b1;
    `uvm_info("TB", "Reset released, simulation starting", UVM_LOW)
  end
  
  // ============================================================================
  // Interface Instantiation
  // ============================================================================
  
  riscv_soc_if dut_if (
    .clk(clk),
    .rst_n(rst_n)
  );
  
  // ============================================================================
  // DUT Instance (RISC-V SoC Top-Level)
  // ============================================================================
  
  riscv_soc_top dut (
    .clk              (clk),
    .rst_n            (rst_n),
    .uart_rx          (dut_if.uart_rx),
    .uart_tx          (dut_if.uart_tx),
    .gpio_in          (dut_if.gpio_in),
    .gpio_out         (dut_if.gpio_out),
    .axi_awaddr       (dut_if.axi_awaddr),
    .axi_awvalid      (dut_if.axi_awvalid),
    .axi_awready      (dut_if.axi_awready),
    .axi_wdata        (dut_if.axi_wdata),
    .axi_wstrb        (dut_if.axi_wstrb),
    .axi_wvalid       (dut_if.axi_wvalid),
    .axi_wready       (dut_if.axi_wready),
    .axi_bresp        (dut_if.axi_bresp),
    .axi_bvalid       (dut_if.axi_bvalid),
    .axi_bready       (dut_if.axi_bready),
    .axi_araddr       (dut_if.axi_araddr),
    .axi_arvalid      (dut_if.axi_arvalid),
    .axi_arready      (dut_if.axi_arready),
    .axi_rdata        (dut_if.axi_rdata),
    .axi_rresp        (dut_if.axi_rresp),
    .axi_rvalid       (dut_if.axi_rvalid),
    .axi_rready       (dut_if.axi_rready),
    .ext_interrupt    (dut_if.ext_interrupt)
  );
  
  // ============================================================================
  // UVM Environment Setup
  // ============================================================================
  
  initial begin
    // Set virtual interface in config database
    uvm_config_db #(virtual riscv_soc_if)::set(null, "*", "vif", dut_if);
    
    // Start UVM test
    run_test();
  end
  
  // ============================================================================
  // Waveform Generation
  // ============================================================================
  
  initial begin
    $dumpfile("riscv_uvm.vcd");
    $dumpvars(0, tb_riscv_uvm);
  end
  
  // ============================================================================
  // Simulation Timeout
  // ============================================================================
  
  initial begin
    #10000000;  // 10 milliseconds
    `uvm_info("TB", "Simulation timeout reached", UVM_LOW)
    $finish;
  end
  
endmodule : tb_riscv_uvm

