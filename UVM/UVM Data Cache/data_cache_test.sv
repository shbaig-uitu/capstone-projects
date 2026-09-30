class data_cache_test extends uvm_test;

    `uvm_component_utils(data_cache_test)

    data_cache_env env;


    function new(string name, uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env =
            data_cache_env::type_id::create(
                "env",
                this
            );

    endfunction


    task run_phase(uvm_phase phase);

        data_cache_seq seq;

        phase.raise_objection(this);

        seq =
            data_cache_seq::type_id::create(
                "seq"
            );

        seq.start(env.agent.sqr);

        phase.drop_objection(this);

    endtask

endclass
