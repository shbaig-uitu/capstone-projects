

class systolic_base_test extends uvm_test;
    `uvm_component_utils(systolic_base_test)
    systolic_env env;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = systolic_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        systolic_random_seq seq = systolic_random_seq::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        #100;
        phase.drop_objection(this);
    endtask
endclass