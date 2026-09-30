class seq_item extends uvm_sequence_item;
 
    rand logic [3:0]  addr0;
    rand logic        read0;
    rand logic        write0;
    rand logic [31:0] wdata0;
    rand logic [3:0]  wmask0;
 
    rand logic [3:0]  addr1;
    rand logic        read1;
    rand logic        write1;
    rand logic [31:0] wdata1;
    rand logic [3:0]  wmask1;
 
    logic [31:0] rdata0;
    logic [31:0] rdata1;
 
    `uvm_object_utils(seq_item)
 
    function new(string name = "seq_item");
        super.new(name);
    endfunction
endclass
