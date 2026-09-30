`ifndef SYSTOLIC_ENV_SV
`define SYSTOLIC_ENV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class systolic_env extends uvm_env;
  `uvm_component_utils(systolic_env)

  systolic_agent      agent;
  systolic_scoreboard scoreboard;
  systolic_coverage   cov;        // <-- Coverage Subscriber

  function new(string name = "systolic_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent      = systolic_agent::type_id::create("agent", this);
    scoreboard = systolic_scoreboard::type_id::create("scoreboard", this);
    cov        = systolic_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Broadcast monitor transactions to both Scoreboard and Coverage
    agent.monitor.item_collected_port.connect(scoreboard.item_collected_export);
    agent.monitor.item_collected_port.connect(cov.analysis_export);
  endfunction

endclass

`endif
