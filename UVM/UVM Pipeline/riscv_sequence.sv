`include "uvm_macros.svh"
import uvm_pkg::*;

class riscv_sequence extends uvm_sequence #(seqs_item);
  `uvm_object_utils(riscv_sequence)

  // ----- HARDCODED INSTRUCTIONS -----
  bit [31:0] instr_list[] = '{
    32'h00500093,   // addi x1, x0, 5
    32'h00600113,   // addi x2, x0, 6
    32'h002081b3    // add  x3, x1, x2   (RAW hazard - forwarding test)
  };

  function new(string name = "riscv_sequence");
    super.new(name);
  endfunction

  task body();
    seqs_item req;

    // teeno instructions ek-ek karke drive karo
    foreach (instr_list[i]) begin
      req = seqs_item::type_id::create("req");
      start_item(req);
      req.instruct_en = 1'b1;
      req.instruction = instr_list[i];
      finish_item(req);
    end

    // enable off - pipeline drain hone do taake result stable dikhe
    repeat (6) begin
      req = seqs_item::type_id::create("req");
      start_item(req);
      req.instruct_en = 1'b0;
      req.instruction = 32'h0;
      finish_item(req);
    end
  endtask
endclass
