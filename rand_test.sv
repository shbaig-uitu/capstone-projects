class rand_test extends base_test;
  `uvm_component_utils(rand_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  task run_phase(uvm_phase phase);
    rand_access_seq seq;
    phase.raise_objection(this);
    reset_dut();
    seq=rand_access_seq::type_id::create("seq");
    seq.start(env.axi.seqr);
    repeat(2) @(posedge vif.clk);
    vif.core_rst_n<=1;
    repeat(2500) @(posedge vif.clk);
    phase.drop_objection(this);
  endtask
endclass
