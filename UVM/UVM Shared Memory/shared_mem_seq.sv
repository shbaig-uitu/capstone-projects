class shared_mem_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(shared_mem_seq)
    function new(string name = "shared_mem_seq");
        super.new(name);
    endfunction
 
    task send(bit [3:0] a0, bit r0, bit w0, bit [31:0] wd0, bit [3:0] wm0,
              bit [3:0] a1, bit r1, bit w1, bit [31:0] wd1, bit [3:0] wm1);
        seq_item it = seq_item::type_id::create("it");
        start_item(it);
        it.addr0 = a0; it.read0 = r0; it.write0 = w0; it.wdata0 = wd0; it.wmask0 = wm0;
        it.addr1 = a1; it.read1 = r1; it.write1 = w1; it.wdata1 = wd1; it.wmask1 = wm1;
        finish_item(it);
    endtask
 
    task body();
        // 1) Port0 write addr=2 -> Port0 read addr=2
        send(4'd2, 0, 1, 32'h1111_1111, 4'hF,   4'd0, 0, 0, 32'h0, 4'h0);
        send(4'd2, 1, 0, 32'h0,         4'h0,   4'd0, 0, 0, 32'h0, 4'h0);
 
        // 2) Port1 write addr=4 -> Port1 read addr=4
        send(4'd0, 0, 0, 32'h0,         4'h0,   4'd4, 0, 1, 32'h2222_2222, 4'hF);
        send(4'd0, 0, 0, 32'h0,         4'h0,   4'd4, 1, 0, 32'h0,         4'h0);
 
        // 3) Port0 write addr=6 -> Port1 read addr=6 (cross-port)
        send(4'd6, 0, 1, 32'h3333_3333, 4'hF,   4'd0, 0, 0, 32'h0, 4'h0);
        send(4'd0, 0, 0, 32'h0,         4'h0,   4'd6, 1, 0, 32'h0, 4'h0);
 
        // 4) Port1 write addr=7 -> Port0 read addr=7 (cross-port)
        send(4'd0, 0, 0, 32'h0,         4'h0,   4'd7, 0, 1, 32'h4444_4444, 4'hF);
        send(4'd7, 1, 0, 32'h0,         4'h0,   4'd0, 0, 0, 32'h0,         4'h0);
 
        // 5) Different address simultaneous writes: addr1 (port0) + addr9 (port1)
        send(4'd1, 0, 1, 32'h5555_5555, 4'hF,   4'd9, 0, 1, 32'h6666_6666, 4'hF);
        send(4'd1, 1, 0, 32'h0,         4'h0,   4'd9, 1, 0, 32'h0,         4'h0);
 
        // 6) Same address collision: addr=10, both write same cycle -> core0 wins
        send(4'd10, 0, 1, 32'h7777_7777, 4'hF,  4'd10, 0, 1, 32'h8888_8888, 4'hF);
        send(4'd10, 1, 0, 32'h0,         4'h0,  4'd10, 1, 0, 32'h0,         4'h0);
 
        // 7) Write mask check: addr=12 full write, then lower-halfword-only write
        send(4'd12, 0, 1, 32'hDEAD_BEEF, 4'hF,  4'd0, 0, 0, 32'h0, 4'h0);
        send(4'd12, 0, 1, 32'h0000_1234, 4'h3,  4'd0, 0, 0, 32'h0, 4'h0); // sirf byte0,1
        send(4'd12, 1, 0, 32'h0,         4'h0,  4'd0, 0, 0, 32'h0, 4'h0);
    endtask
endclass
