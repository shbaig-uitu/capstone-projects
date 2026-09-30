class shared_mem_test extends uvm_test;
    `uvm_component_utils(shared_mem_test)
    shared_mem_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = shared_mem_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        shared_mem_seq seq = shared_mem_seq::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sqr);
        phase.drop_objection(this);
    endtask
endclass
