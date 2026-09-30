

class core_driver_uvm extends uvm_driver #(core_transaction_uvm);

    `uvm_component_utils(core_driver_uvm)

    virtual core_if_uvm vif;

    function new(string name = "core_driver_uvm",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual core_if_uvm)::get(
                this, "", "vif", vif))
            `uvm_fatal("DRIVER", "Virtual interface not found")
    endfunction


    task run_phase(uvm_phase phase);

        // Initial values
        vif.read       <= 0;
        vif.write      <= 0;
        vif.address    <= 0;
        vif.write_data <= 0;

        forever begin

            seq_item_port.get_next_item(req);

            drive_transaction(req);

            seq_item_port.item_done();

        end

    endtask


    task drive_transaction(core_transaction_uvm tr);

        // Drive request
        @(posedge vif.clk);

        vif.read       <= tr.read;
        vif.write      <= tr.write;
        vif.address    <= tr.address;
        vif.write_data <= tr.write_data;

        // Wait until DUT completes request
        do begin
            @(posedge vif.clk);
        end
        while (!vif.ready);

        // Capture response
        tr.ready     = vif.ready;
        tr.read_data = vif.read_data;

        // Remove request
        vif.read       <= 0;
        vif.write      <= 0;
        vif.address    <= 0;
        vif.write_data <= 0;

    endtask

endclass