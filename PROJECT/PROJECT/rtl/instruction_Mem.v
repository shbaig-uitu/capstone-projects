`timescale 1ns/1ps

module instruction_Mem #(
    parameter TEST_FILE = "core0.txt"
)(
    input  wire [31:0] addr,
    output wire [31:0] inst
);

    reg [31:0] i_mem [0:255];

    integer i;

    initial begin

        // Initialize all instruction memory to NOP
        for (i = 0; i < 256; i = i + 1) begin
            i_mem[i] = 32'h00000013;
        end

        // Load program file
        $readmemb(TEST_FILE, i_mem);

    end

    // PC starts from 0x00400000
    wire [31:0] offset_addr;

    assign offset_addr = addr - 32'h00400000;

    // Each instruction = 4 bytes
    assign inst = i_mem[offset_addr[9:2]];

endmodule