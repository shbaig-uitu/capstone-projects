`ifndef AHB_ENV_SV
`define AHB_ENV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_agent.sv"
`include "ahb_scoreboard.sv"
`include "ahb_coverage.sv"

class ahb_env extends uvm_env;

    `uvm_component_utils(ahb_env)

    ahb_agent      agent0;
    ahb_agent      agent1;
    ahb_scoreboard scoreboard;
    ahb_coverage   coverage;

    function new(string name = "ahb_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_db#(int)::set(this, "agent0.monitor", "master_id", 0);
        uvm_config_db#(int)::set(this, "agent1.monitor", "master_id", 1);

        agent0     = ahb_agent::type_id::create("agent0", this);
        agent1     = ahb_agent::type_id::create("agent1", this);
        scoreboard = ahb_scoreboard::type_id::create("scoreboard", this);
        coverage   = ahb_coverage::type_id::create("coverage", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent0.monitor.ap.connect(scoreboard.analysis_export);
        agent1.monitor.ap.connect(scoreboard.analysis_export);
        agent0.monitor.ap.connect(coverage.analysis_export);
        agent1.monitor.ap.connect(coverage.analysis_export);
    endfunction

endclass

`endif
