

class core_transaction_uvm extends uvm_sequence_item;

    rand bit        read;
    rand bit        write;
    rand bit [31:0] address;
    rand bit [31:0] write_data;

    bit [31:0] read_data;
    bit        ready;

    `uvm_object_utils_begin(core_transaction_uvm)
        `uvm_field_int(read,       UVM_ALL_ON)
        `uvm_field_int(write,      UVM_ALL_ON)
        `uvm_field_int(address,    UVM_ALL_ON)
        `uvm_field_int(write_data, UVM_ALL_ON)
        `uvm_field_int(read_data,  UVM_ALL_ON)
        `uvm_field_int(ready,      UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "core_transaction_uvm");
        super.new(name);
    endfunction

    constraint valid_request_c {
        !(read && write);
        (read || write);
    }

endclass