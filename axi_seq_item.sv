class axi_seq_item extends uvm_sequence_item;
  rand bit is_write;
  rand bit [7:0] addr;
  rand bit [31:0] data;
  rand int unsigned idle_cycles;
  `uvm_object_utils_begin(axi_seq_item)
    `uvm_field_int(is_write, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(idle_cycles, UVM_ALL_ON)
  `uvm_object_utils_end
  function new(string name="axi_seq_item"); super.new(name); endfunction
endclass
