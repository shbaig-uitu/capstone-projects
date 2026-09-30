

class core_agent_uvm extends uvm_agent;

    `uvm_component_utils(core_agent_uvm)

    uvm_sequencer #(core_transaction_uvm) sequencer;
    core_driver_uvm  driver;
    core_monitor_uvm monitor;

    function new(string name = "core_agent_uvm",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sequencer = uvm_sequencer #(core_transaction_uvm)::
                    type_id::create("sequencer", this);

        driver = core_driver_uvm::
                 type_id::create("driver", this);

        monitor = core_monitor_uvm::
                  type_id::create("monitor", this);

    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Sequencer → Driver connection
        driver.seq_item_port.connect(
            sequencer.seq_item_export
        );

    endfunction

endclass