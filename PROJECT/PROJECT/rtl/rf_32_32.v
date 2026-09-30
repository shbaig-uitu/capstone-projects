`timescale 1ns/1ps

module rf_32_32 (

    input wire clk,
    input wire reg_write,
    input wire rst,

    input wire [31:0] data_write,

    input wire [4:0] wa,
    input wire [4:0] ra1,
    input wire [4:0] ra2,

    output wire [31:0] rd1,
    output wire [31:0] rd2

);

    reg [31:0] rf [0:31];

    integer i;


    // =====================================================
    // REGISTER WRITE
    // =====================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            for (i = 0; i < 32; i = i + 1)
                rf[i] <= 32'b0;

        end

        else begin

            // x0 hamesha zero rahega
            if (reg_write && wa != 5'd0)
                rf[wa] <= data_write;

            rf[0] <= 32'b0;

        end

    end


    // =====================================================
    // REGISTER READ
    // =====================================================

    assign rd1 = (ra1 == 5'd0) ? 32'b0 : rf[ra1];

    assign rd2 = (ra2 == 5'd0) ? 32'b0 : rf[ra2];

endmodule