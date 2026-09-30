class data_cache_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(data_cache_seq)
    function new(string name = "data_cache_seq");
        super.new(name);
    endfunction
 
    task send(bit [3:0] a, bit r, bit w, bit [31:0] wd, bit [3:0] wm = 4'hF);
        seq_item it = seq_item::type_id::create("it");
        start_item(it);
        it.mem_addr   = a;
        it.mem_read   = r;
        it.mem_write  = w;
        it.cache_i    = wd;
        it.write_mask = wm;
        finish_item(it);
    endtask
 
    task body();
        // 1) addr 3 pe write, phir usi addr read -> HIT
        send(4'd3, 0, 1, 32'hAAAA_1111);
        send(4'd3, 1, 0, 32'h0);
 
        // 2) addr 8 pe seedha read (kabhi likha nahi) -> MISS (cache_o=0)
        send(4'd8, 1, 0, 32'h0);
 
        // 3) addr 5 pe write, addr 6 pe read -> MISS (dusra addr)
        send(4'd5, 0, 1, 32'hBBBB_3333);
        send(4'd6, 1, 0, 32'h0);
 
        // 4) addr 5 wapas read -> HIT
        send(4'd5, 1, 0, 32'h0);
 
        // 5) addr 3 pe 0 likho (zero-data), phir read -> RTL isko MISS treat karega
        send(4'd3, 0, 1, 32'h0);
        send(4'd3, 1, 0, 32'h0);
    endtask
endclass
