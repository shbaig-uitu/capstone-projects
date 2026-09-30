// imem.v (Your Hardware Mask ROM)
`default_nettype none

module imem (
    input  wire [31:0] addr,
    output reg  [31:0] instr
);
    wire [29:0] word_idx = addr[31:2];

    always @(*) begin
        case (word_idx)
            0:  instr = 32'h400000b7; // lui x1, 0x40000
            1:  instr = 32'h00100113; // addi x2, x0, 1
            2:  instr = 32'h04008193; // addi x3, x1, 0x40
            3:  instr = 32'h0c008213; // addi x4, x1, 0xc0
            4:  instr = 32'h0021a023; // sw x2, 0(x3)
            5:  instr = 32'h00110113; // addi x2, x2, 1
            6:  instr = 32'h00418193; // addi x3, x3, 4
            7:  instr = 32'hfe41cae3; // blt x3, x4, -12
            8:  instr = 32'h00100293; // addi x5, x0, 1
            9:  instr = 32'h0050a023; // sw x5, 0(x1)
            10: instr = 32'h0040a283; // lw x5, 4(x1)
            11: instr = 32'h00200313; // addi x6, x0, 2
            12: instr = 32'hfe629ce3; // bne x5, x6, -8
            13: instr = 32'h0000006f; // jal x0, 0 (Halt)
            default: instr = 32'h0000006f; 
        endcase
    end
endmodule
`default_nettype wire
