class riscv_scoreboard extends uvm_subscriber #(seqs_item);
  `uvm_component_utils(riscv_scoreboard)

  logic [31:0] expected_result = 32'h0000000B;   // 5 + 6 = 11

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void write(seqs_item t);
    `uvm_info("SCBD", $sformatf("Received: instruct_en=%0b result=%0h",
              t.instruct_en, t.result), UVM_LOW)

    if (t.result == expected_result)
      `uvm_info("SCBD", $sformatf("MATCH: result = %0h (expected)", t.result), UVM_LOW)
  endfunction
endclass
