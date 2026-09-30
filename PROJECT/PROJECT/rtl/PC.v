`timescale 1ns/1ps

module PC (
    input clk,
    input en,
    input rst,
    input [31:0] addr_in,
    output reg [31:0] addr_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            addr_out <= 32'h00400000;
        else if (en)
            addr_out <= addr_in;
    end

endmodule