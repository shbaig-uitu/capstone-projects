`ifndef SYSTOLIC_SEQ_ITEM_SV
`define SYSTOLIC_SEQ_ITEM_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class systolic_seq_item extends uvm_sequence_item;

  // Randomized Transaction Fields
  typedef enum bit { READ = 1'b0, WRITE = 1'b1 } op_type_e;

  rand op_type_e    op;
  rand bit [31:0]   addr;
  rand bit [31:0]   data;
       bit [31:0]   rdata;
       bit [1:0]    resp;

  // UVM Field Automation Macros
  `uvm_object_utils_begin(systolic_seq_item)
    `uvm_field_enum(op_type_e, op, UVM_ALL_ON)
    `uvm_field_int(addr,          UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(data,          UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(rdata,         UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(resp,          UVM_ALL_ON | UVM_HEX)
  `uvm_object_utils_end

  function new(string name = "systolic_seq_item");
    super.new(name);
  endfunction

  // Constraint: Word-aligned addresses within accelerator space
  constraint c_addr_align {
    addr[1:0] == 2'b00;
    addr[31:8] == 24'h0; // Local offset (0x00 to 0x7C)
  }

endclass

`endif
