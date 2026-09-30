class shared_mem_monitor extends uvm_monitor;
    `uvm_component_utils(shared_mem_monitor)
    virtual shared_mem_if vif;
    uvm_analysis_port #(seq_item) ap;
 
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual shared_mem_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "vif not set")
    endfunction
 
    task run_phase(uvm_phase phase);
        forever begin
            seq_item it;
            @(posedge vif.clk);
            #1;
            if (vif.read0 || vif.write0 || vif.read1 || vif.write1) begin
                it = seq_item::type_id::create("it");
                it.addr0 = vif.addr0; it.read0 = vif.read0; it.write0 = vif.write0;
                it.wdata0 = vif.wdata0; it.wmask0 = vif.wmask0;
                it.addr1 = vif.addr1; it.read1 = vif.read1; it.write1 = vif.write1;
                it.wdata1 = vif.wdata1; it.wmask1 = vif.wmask1;
                it.rdata0 = vif.rdata0;
                it.rdata1 = vif.rdata1;
                ap.write(it);
            end
        end
    endtask
endclass
