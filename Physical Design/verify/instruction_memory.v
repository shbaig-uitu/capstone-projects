`timescale 1ns / 1ps
module instruction_memory (
    input  wire [31:0] pc,
    output wire [31:0] inst
);

    reg [31:0] memory [0:255];

    assign inst = memory[pc[9:2]];

    initial begin
        $readmemh("instructions.hex", memory);
    end

endmodule
