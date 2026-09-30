

class systolic_env extends uvm_env;
    `uvm_component_utils(systolic_env)
    systolic_agent     agent;
    systolic_scoreboard scb;
    systolic_coverage   cov;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = systolic_agent::type_id::create("agent", this);
        scb   = systolic_scoreboard::type_id::create("scb", this);
        cov   = systolic_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.monitor.mon_ap.connect(scb.item_imp);
        agent.monitor.mon_ap.connect(cov.analysis_export);
    endfunction
endclass