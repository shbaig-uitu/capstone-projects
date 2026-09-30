/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: riscv_soc_wrapper.sv
 * Description: FPGA Wrapper for Arty100T
 *              Instantiates SoC top-level, interfaces with board peripherals
 */

`include "riscv_defines.sv"

module riscv_soc_wrapper (
  input  logic          clk_100m,
  input  logic          btn_reset_n,
  
  // UART Interface
  input  logic          uart_rx,
  output logic          uart_tx,
  
  // GPIO LEDs (output only for now)
  output logic [7:0]    gpio_out,
  
  // GPIO Switches (input)
  input  logic [3:0]    gpio_in
);

  // ============================================================================
  // Clock and Reset Generation
  // ============================================================================
  
  logic clk;
  logic rst_n;
  logic pll_locked;
  
  // Clock divider for debugging (optional)
  logic clk_div;
  logic [31:0] clk_div_cnt = 0;
  
  always @(posedge clk_100m or negedge btn_reset_n) begin
    if (!btn_reset_n) begin
      clk_div_cnt <= 0;
      clk_div <= 0;
    end else begin
      clk_div_cnt <= clk_div_cnt + 1;
      if (clk_div_cnt == 32'd50000000) begin
        clk_div <= ~clk_div;
        clk_div_cnt <= 0;
      end
    end
  end
  
  // Use 100MHz clock directly for now
  // In production, use a PLL for higher speeds (200MHz, 300MHz)
  assign clk = clk_100m;
  assign rst_n = btn_reset_n;
  assign pll_locked = 1'b1;

  // ============================================================================
  // RISC-V SoC Top-Level Instantiation
  // ============================================================================
  
  riscv_soc_top soc_inst (
    .clk              (clk),
    .rst_n            (rst_n),
    
    .uart_rx          (uart_rx),
    .uart_tx          (uart_tx),
    
    .gpio_in          ({4'b0, gpio_in}),
    .gpio_out         (gpio_out),
    
    // AXI4-Lite Debug Interface (not connected for now)
    .axi_awaddr       (32'h0),
    .axi_awvalid      (1'b0),
    .axi_awready      (),
    
    .axi_wdata        (32'h0),
    .axi_wstrb        (4'h0),
    .axi_wvalid       (1'b0),
    .axi_wready       (),
    
    .axi_bresp        (),
    .axi_bvalid       (),
    .axi_bready       (1'b1),
    
    .axi_araddr       (32'h0),
    .axi_arvalid      (1'b0),
    .axi_arready      (),
    
    .axi_rdata        (),
    .axi_rresp        (),
    .axi_rvalid       (),
    .axi_rready       (1'b1),
    
    .ext_interrupt    (1'b0)
  );

  // ============================================================================
  // LED Debug Indicators (Optional)
  // ============================================================================
  
  // Drive LEDs with status signals
  assign gpio_out[0] = clk_div;              // Blinking LED
  assign gpio_out[1] = pll_locked;           // PLL Lock status
  assign gpio_out[2] = rst_n;                // Reset status
  assign gpio_out[3] = uart_tx;              // UART TX indicator

endmodule
