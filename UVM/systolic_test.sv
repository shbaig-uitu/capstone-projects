`ifndef SYSTOLIC_TEST_SV
`define SYSTOLIC_TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class systolic_base_test extends uvm_test;
  `uvm_component_utils(systolic_base_test)

  systolic_env env;

  function new(string name = "systolic_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = systolic_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    systolic_random_seq seq;
    seq = systolic_random_seq::type_id::create("seq");

    phase.raise_objection(this, "Starting Random Sequence");
    `uvm_info("TEST", "Starting 4x4 Systolic Array UVM Verification Run...", UVM_LOW)

    // Run the matrix multiplication sequence
    seq.start(env.agent.seqr);

    #100ns;
    `uvm_info("TEST", "Verification Sequence Completed.", UVM_LOW)
    phase.drop_objection(this, "Sequence Finished");
  endtask

endclass

`endif
