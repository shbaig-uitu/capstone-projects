
class core_monitor_uvm extends uvm_monitor;

    `uvm_component_utils(core_monitor_uvm)

    virtual core_if_uvm vif;

    uvm_analysis_port #(core_transaction_uvm) ap;

    function new(string name = "core_monitor_uvm",
                 uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual core_if_uvm)::get(
                this, "", "vif", vif))
            `uvm_fatal("MONITOR", "Virtual interface not found")
    endfunction


    task run_phase(uvm_phase phase);

        core_transaction_uvm tr;

        forever begin

            @(posedge vif.clk);

            // Completed valid transaction
            if ((vif.read || vif.write) && vif.ready) begin

                tr = core_transaction_uvm::type_id::create("tr");

                tr.read       = vif.read;
                tr.write      = vif.write;
                tr.address    = vif.address;
                tr.write_data = vif.write_data;
                tr.read_data  = vif.read_data;
                tr.ready      = vif.ready;

                ap.write(tr);

                `uvm_info("MONITOR",
                    $sformatf(
                    "READ=%0b WRITE=%0b ADDR=%08h WDATA=%08h RDATA=%08h",
                    tr.read,
                    tr.write,
                    tr.address,
                    tr.write_data,
                    tr.read_data),
                    UVM_MEDIUM)

            end
        end

    endtask

endclass