class shared_mem_scoreboard extends uvm_subscriber #(seq_item);
    `uvm_component_utils(shared_mem_scoreboard)

    bit [31:0] ref_mem [0:15];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void write(seq_item t);

        bit collision = t.write0 && t.write1 && (t.addr0 == t.addr1);

        // --------------------------------
        // CORE 0 WRITE
        // --------------------------------
        if (t.write0) begin
            if (t.wmask0[0])
                ref_mem[t.addr0][7:0]   = t.wdata0[7:0];

            if (t.wmask0[1])
                ref_mem[t.addr0][15:8]  = t.wdata0[15:8];

            if (t.wmask0[2])
                ref_mem[t.addr0][23:16] = t.wdata0[23:16];

            if (t.wmask0[3])
                ref_mem[t.addr0][31:24] = t.wdata0[31:24];
        end

        // --------------------------------
        // CORE 1 WRITE
        // Only if no collision
        // --------------------------------
        if (t.write1 && !collision) begin
            if (t.wmask1[0])
                ref_mem[t.addr1][7:0]   = t.wdata1[7:0];

            if (t.wmask1[1])
                ref_mem[t.addr1][15:8]  = t.wdata1[15:8];

            if (t.wmask1[2])
                ref_mem[t.addr1][23:16] = t.wdata1[23:16];

            if (t.wmask1[3])
                ref_mem[t.addr1][31:24] = t.wdata1[31:24];
        end

        // --------------------------------
        // COLLISION
        // --------------------------------
        if (collision)`uvm_info("SB", $sformatf("COLLISION addr=%0d: core0 wins, core1 write dropped", t.addr0), UVM_LOW)

        // --------------------------------
        // CORE 0 READ CHECK
        // --------------------------------
        if (t.read0) begin
            if (t.rdata0 !== ref_mem[t.addr0])
                `uvm_error("SB",$sformatf("rdata0 MISMATCH addr=%0d: expected=%0h got=%0h",t.addr0, ref_mem[t.addr0], t.rdata0))
            else
                `uvm_info("SB",$sformatf("rdata0 OK addr=%0d -> %0h", t.addr0,t.rdata0), UVM_LOW)
        end

        // --------------------------------
        // CORE 1 READ CHECK
        // --------------------------------
        if (t.read1) begin
            if (t.rdata1 !== ref_mem[t.addr1])
                `uvm_error("SB", $sformatf( "rdata1 MISMATCH addr=%0d: expected=%0h got=%0h", t.addr1, ref_mem[t.addr1], t.rdata1))
            else
                `uvm_info("SB", $sformatf("rdata1 OK addr=%0d -> %0h", t.addr1, t.rdata1), UVM_LOW)
        end

    endfunction

endclass
