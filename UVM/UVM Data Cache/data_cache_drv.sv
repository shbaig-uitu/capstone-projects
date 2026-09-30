class data_cache_drv extends uvm_driver #(seq_item);
    `uvm_component_utils(data_cache_drv)
    virtual data_cache_if vif;
 
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual data_cache_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "vif not set")
    endfunction
 
    task run_phase(uvm_phase phase);
        forever begin
            seq_item it;
            seq_item_port.get_next_item(it);
 
            @(negedge vif.clk);
            vif.mem_addr   = it.mem_addr;
            vif.mem_read   = it.mem_read;
            vif.mem_write  = it.mem_write;
            vif.cache_i    = it.cache_i;
            vif.write_mask = it.write_mask;
 
            @(posedge vif.clk);
            #1;
            it.cache_o = vif.cache_o;
 
            seq_item_port.item_done();
        end
    endtask
endclass
