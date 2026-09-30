typedef uvm_sequencer #(seq_item) shared_mem_sequencer;
 
class shared_mem_agent extends uvm_agent;
    `uvm_component_utils(shared_mem_agent)
 
    shared_mem_driver    drv;
    shared_mem_sequencer sqr;
    shared_mem_monitor   mon;
 
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = shared_mem_driver::type_id::create("drv", this);
        sqr = shared_mem_sequencer::type_id::create("sqr", this);
        mon = shared_mem_monitor::type_id::create("mon", this);
    endfunction
 
    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass
