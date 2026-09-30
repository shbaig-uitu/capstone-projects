`include "rv32i_soc_defines.v"

module imem #(
    parameter DEPTH    = 1024,
    parameter INIT_FILE = ""
) (
    input  wire [31:0] addr,
    output wire [31:0] rdata
);

    reg [31:0] mem [0:DEPTH-1];

    wire [31:0] word_index = addr[31:2];

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    assign rdata = (word_index < DEPTH) ? mem[word_index] : 32'h0000_0013;

endmodule
