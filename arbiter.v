`include "rv32i_soc_defines.v"

module arbiter (
    input  wire clk,
    input  wire rst_n,

    input  wire req0,
    input  wire req1,

    output reg  grant0,
    output reg  grant1
);

    reg last_grant;

    always @(*) begin
        grant0 = 1'b0;
        grant1 = 1'b0;

        if (req0 && !req1) begin
            grant0 = 1'b1;
        end else if (!req0 && req1) begin
            grant1 = 1'b1;
        end else if (req0 && req1) begin
            if (last_grant == 1'b0) begin
                grant1 = 1'b1;
            end else begin
                grant0 = 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            last_grant <= 1'b0;
        end else begin
            if (grant0) begin
                last_grant <= 1'b0;
            end else if (grant1) begin
                last_grant <= 1'b1;
            end
        end
    end

endmodule
