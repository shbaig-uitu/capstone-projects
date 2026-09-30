

class soc_env_uvm extends uvm_env;

    `uvm_component_utils(soc_env_uvm)

    core_agent_uvm     core0_agent;
    core_agent_uvm     core1_agent;
    soc_scoreboard_uvm scoreboard;

    function new(string name = "soc_env_uvm",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        core0_agent = core_agent_uvm::
                      type_id::create("core0_agent", this);

        core1_agent = core_agent_uvm::
                      type_id::create("core1_agent", this);

        scoreboard = soc_scoreboard_uvm::
                     type_id::create("scoreboard", this);

    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Core0 monitor → Scoreboard
        core0_agent.monitor.ap.connect(
            scoreboard.core0_imp
        );

        // Core1 monitor → Scoreboard
        core1_agent.monitor.ap.connect(
            scoreboard.core1_imp
        );

    endfunction

endclass