class seq_item extends uvm_sequence_item;

    rand logic [3:0]  mem_addr;
    logic             mem_read;
    logic             mem_write;
    rand logic [31:0] cache_i;
    logic [31:0]      cache_o;
    logic [3:0]       write_mask;

    `uvm_object_utils(seq_item)

    function new(string name = "seq_item");
        super.new(name);
    endfunction

endclass
