typedef uvm_sequencer #(seq_item) cache_sequencer;

class data_cache_agent extends uvm_agent;

    `uvm_component_utils(data_cache_agent)

    data_cache_drv    drv;
    cache_sequencer sqr;
    data_cache_mon   mon;


    function new(string name, uvm_component parent);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        drv = data_cache_drv::type_id::create("drv", this);

        sqr = cache_sequencer::type_id::create("sqr", this);

        mon = data_cache_mon::type_id::create("mon", this);

    endfunction


    function void connect_phase(uvm_phase phase);

        drv.seq_item_port.connect(
            sqr.seq_item_export
        );

    endfunction

endclass
