class data_cache_env extends uvm_env;

    `uvm_component_utils(data_cache_env)

    data_cache_agent      agent;
    data_cache_scoreboard sb;


    function new(string name, uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        agent = data_cache_agent::type_id::create("agent",this);

        sb = data_cache_scoreboard::type_id::create("sb",this);

    endfunction


    function void connect_phase(uvm_phase phase);

        agent.mon.ap.connect(sb.analysis_export);

    endfunction

endclass
