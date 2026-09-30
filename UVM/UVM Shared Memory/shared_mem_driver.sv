class shared_mem_driver extends uvm_driver #(seq_item);
    `uvm_component_utils(shared_mem_driver)
    virtual shared_mem_if vif;
 
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual shared_mem_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "vif not set")
    endfunction
 
    task run_phase(uvm_phase phase);
        forever begin
            seq_item it;
            seq_item_port.get_next_item(it);
 
            @(negedge vif.clk);
            vif.addr0  = it.addr0;  vif.read0  = it.read0;  vif.write0 = it.write0;
            vif.wdata0 = it.wdata0; vif.wmask0 = it.wmask0;
            vif.addr1  = it.addr1;  vif.read1  = it.read1;  vif.write1 = it.write1;
            vif.wdata1 = it.wdata1; vif.wmask1 = it.wmask1;
 
            @(posedge vif.clk);
            #1;
            it.rdata0 = vif.rdata0;
            it.rdata1 = vif.rdata1;
 
            seq_item_port.item_done();
        end
    endtask
endclass
