
typedef enum {AXI_WRITE, AXI_READ} axi_op_e;

class axi_seq_item extends uvm_sequence_item;
    rand axi_op_e       op;
    rand logic [31:0]   addr;
    rand logic [31:0]   data;
    logic [31:0]        rdata;

    `uvm_object_utils_begin(axi_seq_item)
        `uvm_field_enum(axi_op_e, op, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(data, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(rdata, UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "axi_seq_item");
        super.new(name);
    endfunction
endclass