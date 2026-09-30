module tb_top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import riscv_pkg::*;

  logic clk;
  logic rst;

  // Clock Generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset Generation
  initial begin
    rst = 1;
    #15 rst = 0;
  end

  // Interface Instantiation
  riscv_if vif(clk, rst);

  // DUT Instantiation (Interface signals ko DUT ke sath connect karein)
  topmodule u_dut (
    .clk         (vif.clk),
    .rst         (vif.rst),
    .instruct_en (vif.instruct_en),
    .instruction (vif.instruction),
    .result      (vif.result) // Result line ko connect karein
  );

  // Pass interface to UVM Config DB
  initial begin
    uvm_config_db#(virtual riscv_if)::set(null, "*", "vif", vif);
    run_test(); // Command line +UVM_TESTNAME will handle execution
  end
endmodule
