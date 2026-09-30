class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  soc_env env; virtual soc_if vif;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=soc_env::type_id::create("env",this);
    if(!uvm_config_db#(virtual soc_if)::get(this,"","vif",vif)) `uvm_fatal("NOVIF","vif missing");
  endfunction
  task reset_dut();
    vif.rst_n<=0; vif.core_rst_n<=0;
    repeat(5) @(posedge vif.clk);
    vif.rst_n<=1;
    repeat(3) @(posedge vif.clk);
  endtask
  task run_phase(uvm_phase phase);
    page_table_prog_seq seq;
    phase.raise_objection(this);
    reset_dut();
    seq=page_table_prog_seq::type_id::create("seq");
    seq.start(env.axi.seqr);
    repeat(2) @(posedge vif.clk);
    vif.core_rst_n<=1;
    repeat(2500) @(posedge vif.clk);
    phase.drop_objection(this);
  endtask
endclass
