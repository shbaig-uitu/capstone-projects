`timescale 1ns/1ps

module round_robin_arbiter (

    input  wire clk,
    input  wire rst,

    // Requests from two cores
    input  wire req0,
    input  wire req1,

    // Grant signals
    output reg  grant0,
    output reg  grant1

);

    // ---------------------------------------------------------
    // Last granted core
    //
    // last_grant = 0 ? Core 0 was served last
    // last_grant = 1 ? Core 1 was served last
    // ---------------------------------------------------------
    reg last_grant;

    always @(posedge clk) begin

        if (rst) begin

            grant0     <= 1'b0;
            grant1     <= 1'b0;
            last_grant <= 1'b1;

        end

        else begin

            // Default: no grant
            grant0 <= 1'b0;
            grant1 <= 1'b0;

            // -------------------------------------------------
            // Only Core 0 requests
            // -------------------------------------------------
            if (req0 && !req1) begin

                grant0     <= 1'b1;
                last_grant <= 1'b0;

            end

            // -------------------------------------------------
            // Only Core 1 requests
            // -------------------------------------------------
            else if (!req0 && req1) begin

                grant1     <= 1'b1;
                last_grant <= 1'b1;

            end

            // -------------------------------------------------
            // Both cores request simultaneously
            // Round-Robin arbitration
            // -------------------------------------------------
            else if (req0 && req1) begin

                if (last_grant == 1'b0) begin

                    // Core 0 was served last
                    // Now give priority to Core 1
                    grant1     <= 1'b1;
                    last_grant <= 1'b1;

                end

                else begin

                    // Core 1 was served last
                    // Now give priority to Core 0
                    grant0     <= 1'b1;
                    last_grant <= 1'b0;

                end

            end

        end

    end

endmodule
