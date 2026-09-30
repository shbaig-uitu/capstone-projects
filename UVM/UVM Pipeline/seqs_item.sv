
class seqs_item extends uvm_sequence_item;
  `uvm_object_utils(seqs_item)

  rand bit          instruct_en;   // 1 = valid instruction is cycle, 0 = NOP
  rand logic [31:0] instruction;   // hardcoded instructions sequence se aayengi
  logic      [31:0] result;        // monitor ye field fill karega (return path)

  function new(string name = "seqs_item");
    super.new(name);
  endfunction
endclass