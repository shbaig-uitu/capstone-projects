`ifndef AHB_AGENT_SV
`define AHB_AGENT_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_sequencer.sv"
`include "ahb_driver.sv"
`include "ahb_monitor.sv"

class ahb_agent extends uvm_component;

    `uvm_component_utils(ahb_agent)

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    ahb_sequencer sequencer;
    ahb_driver    driver;
    ahb_monitor   monitor;

    function new(string name = "ahb_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        monitor = ahb_monitor::type_id::create("monitor", this);

        if (is_active == UVM_ACTIVE) begin
            sequencer = ahb_sequencer::type_id::create("sequencer", this);
            driver    = ahb_driver::type_id::create("driver", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction

endclass

`endif
