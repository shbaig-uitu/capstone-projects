`ifndef SYSTOLIC_COVERAGE_SV
`define SYSTOLIC_COVERAGE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class systolic_coverage extends uvm_subscriber #(systolic_seq_item);
  `uvm_component_utils(systolic_coverage)

  systolic_seq_item item;

  covergroup cg_axi_systolic;
    option.per_instance = 1;

    // 1. Bus Operations (Read & Write)
    cp_op: coverpoint item.op {
      bins write_op = {systolic_seq_item::WRITE};
      bins read_op  = {systolic_seq_item::READ};
    }

    // 2. Write Address Bins (Sirf 4-byte aligned registers)
    cp_wr_addr: coverpoint item.addr iff (item.op == systolic_seq_item::WRITE) {
      bins ctrl_reg   = {32'h00};
      bins mat_a_rows = {32'h10, 32'h14, 32'h18, 32'h1C};
      bins mat_b_cols = {32'h20, 32'h24, 32'h28, 32'h2C};
    }

    // 3. Read Address Bins (Status + Tamam 16 Matrix C Outputs)
    cp_rd_addr: coverpoint item.addr iff (item.op == systolic_seq_item::READ) {
      bins status_reg = {32'h04};
      bins mat_c_outs = {
        32'h40, 32'h44, 32'h48, 32'h4C,
        32'h50, 32'h54, 32'h58, 32'h5C,
        32'h60, 32'h64, 32'h68, 32'h6C,
        32'h70, 32'h74, 32'h78, 32'h7C
      };
    }

    // 4. Data Boundaries (Zero, Intermediate, Max Saturation)
    cp_data: coverpoint item.data[7:0] iff (item.op == systolic_seq_item::WRITE) {
      bins min_val = {8'h00};
      bins mid_val = {[8'h01 : 8'hFE]};
      bins max_val = {8'hFF};
    }
  endgroup

  function new(string name = "systolic_coverage", uvm_component parent = null);
    super.new(name, parent);
    cg_axi_systolic = new();
  endfunction

  function void write(systolic_seq_item t);
    this.item = t;
    cg_axi_systolic.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV_REPORT", $sformatf("Achieved Functional Coverage = %0.2f %%", cg_axi_systolic.get_coverage()), UVM_NONE)
  endfunction

endclass

`endif
