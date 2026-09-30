/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: sram_sp.sv
 * Description: Single-port SRAM module
 *              Used for instruction and data memory
 */

`include "../include/riscv_defines.sv"

module sram_sp #(
  parameter DEPTH = `INST_MEM_DEPTH,
  parameter WIDTH = `DATA_WIDTH,
  parameter ADDR_WIDTH = $clog2(DEPTH),
  parameter INIT_FILE = ""
) (
  input  logic                  clk,
  input  logic                  rst_n,
  
  input  logic [ADDR_WIDTH-1:0] addr,
  input  logic                  write_en,
  input  logic [WIDTH-1:0]      write_data,
  input  logic [WIDTH/8-1:0]    byte_en,
  output logic [WIDTH-1:0]      read_data,
  
  input  logic                  valid,
  output logic                  ready
);

  // ============================================================================
  // Memory Array
  // ============================================================================
  
  logic [WIDTH-1:0] mem [0:DEPTH-1];
  logic [ADDR_WIDTH-1:0] addr_reg;

  // ============================================================================
  // Initialization
  // ============================================================================
  
  initial begin
    for (int i = 0; i < DEPTH; i = i + 1)
      mem[i] = '0;
    
    if (INIT_FILE != "")
      $readmemh(INIT_FILE, mem);
  end

  // ============================================================================
  // Read Operation (Synchronous)
  // ============================================================================
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      addr_reg <= '0;
      read_data <= '0;
    end else if (valid && !write_en) begin
      addr_reg <= addr;
      read_data <= mem[addr];
    end
  end

  // ============================================================================
  // Write Operation (Synchronous)
  // ============================================================================
  
  always_ff @(posedge clk) begin
    if (valid && write_en) begin
      for (int i = 0; i < WIDTH/8; i = i + 1) begin
        if (byte_en[i])
          mem[addr][(i+1)*8-1:i*8] <= write_data[(i+1)*8-1:i*8];
      end
    end
  end

  // ============================================================================
  // Ready Signal (1-cycle latency)
  // ============================================================================
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ready <= 1'b0;
    end else begin
      ready <= valid;
    end
  end

endmodule
