

class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)
    virtual axi_if vif;
    uvm_analysis_port #(axi_seq_item) mon_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get virtual interface vif")
    endfunction

    task run_phase(uvm_phase phase);
        fork
            sample_writes();
            sample_reads();
        join
    endtask

    task sample_writes();
        axi_seq_item item;
        logic [31:0] captured_addr;
        logic [31:0] captured_data;
        forever begin
            @(posedge vif.clk);
            if (vif.awvalid && vif.awready) captured_addr = vif.awaddr;
            if (vif.wvalid && vif.wready)   captured_data = vif.wdata;
            if (vif.bvalid && vif.bready) begin
                item = axi_seq_item::type_id::create("item");
                item.op   = AXI_WRITE;
                item.addr = captured_addr;
                item.data = captured_data;
                mon_ap.write(item);
            end
        end
    endtask

    task sample_reads();
        axi_seq_item item;
        logic [31:0] captured_addr;
        forever begin
            @(posedge vif.clk);
            if (vif.arvalid && vif.arready) captured_addr = vif.araddr;
            if (vif.rvalid && vif.rready) begin
                item = axi_seq_item::type_id::create("item");
                item.op    = AXI_READ;
                item.addr  = captured_addr;
                item.rdata = vif.rdata;
                mon_ap.write(item);
            end
        end
    endtask
endclass