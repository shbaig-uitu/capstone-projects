class data_cache_mon extends uvm_monitor;
    `uvm_component_utils(data_cache_mon)
    virtual data_cache_if vif;
    uvm_analysis_port #(seq_item) ap;
 
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual data_cache_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "vif not set")
    endfunction
 
    task run_phase(uvm_phase phase);
        forever begin
            seq_item it;
            @(posedge vif.clk);
            #1;
            if (vif.mem_read || vif.mem_write) begin
                it = seq_item::type_id::create("it");
                it.mem_addr   = vif.mem_addr;
                it.mem_read   = vif.mem_read;
                it.mem_write  = vif.mem_write;
                it.cache_i    = vif.cache_i;
                it.write_mask = vif.write_mask;
                it.cache_o    = vif.cache_o;
                ap.write(it);
            end
        end
    endtask
endclass
