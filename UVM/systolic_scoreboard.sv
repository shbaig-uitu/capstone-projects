`ifndef SYSTOLIC_SCOREBOARD_SV
`define SYSTOLIC_SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class systolic_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(systolic_scoreboard)

  uvm_analysis_imp #(systolic_seq_item, systolic_scoreboard) item_collected_export;

  // Local storage for tracking inputs and reference outputs
  bit [7:0]  mat_a [0:3][0:3];
  bit [7:0]  mat_b [0:3][0:3];
  bit [31:0] expected_c [0:3][0:3];

  int match_count = 0;
  int mismatch_count = 0;

  function new(string name = "systolic_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    item_collected_export = new("item_collected_export", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Receive transaction from Monitor
  function void write(systolic_seq_item trans);
    if (trans.op == systolic_seq_item::WRITE) begin
      handle_write(trans.addr, trans.data);
    end else begin
      handle_read(trans.addr, trans.rdata);
    end
  endfunction

  function void handle_write(bit [31:0] addr, bit [31:0] data);
    // Unpack Matrix A rows (Offsets 0x10, 0x14, 0x18, 0x1C)
    if (addr >= 32'h10 && addr <= 32'h1C) begin
      int row = (addr - 32'h10) >> 2;
      mat_a[row][0] = data[7:0];
      mat_a[row][1] = data[15:8];
      mat_a[row][2] = data[23:16];
      mat_a[row][3] = data[31:24];
    end
    // Unpack Matrix B cols (Offsets 0x20, 0x24, 0x28, 0x2C)
    else if (addr >= 32'h20 && addr <= 32'h2C) begin
      int col = (addr - 32'h20) >> 2;
      mat_b[0][col] = data[7:0];
      mat_b[1][col] = data[15:8];
      mat_b[2][col] = data[23:16];
      mat_b[3][col] = data[31:24];
    end
    // Execution Trigger at Offset 0x00
    else if (addr == 32'h00 && data[0] == 1'b1) begin
      compute_golden_matrix();
    end
  endfunction

  function void compute_golden_matrix();
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        expected_c[i][j] = 0;
        for (int k = 0; k < 4; k++) begin
          expected_c[i][j] += mat_a[i][k] * mat_b[k][j];
        end
      end
    end
    `uvm_info("SCB", "Golden Matrix Multiplied successfully!", UVM_LOW)
  endfunction

  function void handle_read(bit [31:0] addr, bit [31:0] rdata);
    // Check Matrix C results (Offsets 0x40 to 0x7C)
    if (addr >= 32'h40 && addr <= 32'h7C) begin
      int cell_idx = (addr - 32'h40) >> 2;
      int r = cell_idx / 4;
      int c = cell_idx % 4;

      if (rdata == expected_c[r][c]) begin
        `uvm_info("SCB_PASS", $sformatf("MATCH: C[%0d][%0d] = %0d (Expected: %0d)", r, c, rdata, expected_c[r][c]), UVM_LOW)
        match_count++;
      end else begin
        `uvm_error("SCB_FAIL", $sformatf("MISMATCH: C[%0d][%0d] = %0d (Expected: %0d)", r, c, rdata, expected_c[r][c]))
        mismatch_count++;
      end
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB_FINAL", $sformatf("Total Matches = %0d | Total Mismatches = %0d", match_count, mismatch_count), UVM_NONE)
  endfunction

endclass

`endif