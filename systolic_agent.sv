
typedef uvm_sequencer #(axi_seq_item) axi_sequencer;

class systolic_agent extends uvm_agent;
    `uvm_component_utils(systolic_agent)
    axi_driver    driver;
    axi_monitor   monitor;
    axi_sequencer sequencer;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver    = axi_driver::type_id::create("driver", this);
        sequencer = axi_sequencer::type_id::create("sequencer", this);
        monitor   = axi_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass