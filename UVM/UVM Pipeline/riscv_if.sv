interface riscv_if(input logic clk, input logic rst);
  logic        instruct_en;
  logic [31:0] instruction;   // DUT ka genuine input port - driver drive karega
  logic [31:0] result;
endinterface

