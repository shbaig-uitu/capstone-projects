

class systolic_random_seq extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(systolic_random_seq)
    function new(string name = "systolic_random_seq"); super.new(name); endfunction

    task body();
        axi_seq_item item = axi_seq_item::type_id::create("item");

        // 1. Write Random Weights (0x40 to 0x7C)
        for (int i = 0; i < 16; i++) begin
            start_item(item);
            item.op   = AXI_WRITE;
            item.addr = 32'h40 + (i * 4);
            item.data = $urandom_range(0, 15); // Small numbers to inspect easily
            finish_item(item);
        end

        // 2. Write Random Activations (0x80 to 0xBC)
        for (int i = 0; i < 16; i++) begin
            start_item(item);
            item.op   = AXI_WRITE;
            item.addr = 32'h80 + (i * 4);
            item.data = $urandom_range(0, 15);
            finish_item(item);
        end

        // 3. Trigger Start (Address 0x00, Bit 0 = 1)
        start_item(item);
        item.op   = AXI_WRITE;
        item.addr = 32'h00;
        item.data = 32'h01;
        finish_item(item);

        // 4. Poll Done Status (Address 0x04, Bit 1 == 1)
        forever begin
            start_item(item);
            item.op   = AXI_READ;
            item.addr = 32'h04;
            finish_item(item);
            if (item.rdata[1] == 1'b1) break;
            #20;
        end

        // 5. Read Result Matrix (0xC0 to 0xFC)
        for (int i = 0; i < 16; i++) begin
            start_item(item);
            item.op   = AXI_READ;
            item.addr = 32'hC0 + (i * 4);
            finish_item(item);
        end
    endtask
endclass