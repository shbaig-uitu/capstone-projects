`include "uvm_macros.svh"
import uvm_pkg::*;
import riscv_pkg::*;

class riscv_test extends uvm_test;
  `uvm_component_utils(riscv_test) // <-- FEORY REGISTRATION MUST BE HERE

  riscv_env env;

  function new(string name = "riscv_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = riscv_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    riscv_sequence seq;
    phase.raise_objection(this);
    seq = riscv_sequence::type_id::create("seq");
    seq.start(env.agent.sequencer); // Adjust hierarchy according to your agent/sequencer
    phase.drop_objection(this);
  endtask
endclass
