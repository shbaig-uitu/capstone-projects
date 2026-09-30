`timescale 1ns/1ps

module shared_sram (

    input  wire        clk,
    input  wire        rst,

    // Request from interconnect
    input  wire        req,
    input  wire        write_en,

    // Address
    input  wire [31:0] addr,

    // Write data
    input  wire [31:0] wdata,

    // Read data
    output reg  [31:0] rdata,

    // Response
    output reg         ready,
    output reg         error

);

    // =========================================================
    // SHARED SRAM
    //
    // 16K words  32 bits
    //
    // Total = 64 KB
    // =========================================================

    reg [31:0] mem [0:16383];

    // Address inside SRAM
    wire [13:0] word_addr;

    assign word_addr = addr[15:2];


    // =========================================================
    // MEMORY OPERATION
    // =========================================================

    always @(posedge clk) begin

        if (rst) begin

            rdata <= 32'b0;
            ready <= 1'b0;
            error <= 1'b0;

        end

        else begin

            // Default values
            ready <= 1'b0;
            error <= 1'b0;

            // Valid request
            if (req) begin

                // ---------------------------------------------
                // WRITE OPERATION
                // ---------------------------------------------
                if (write_en) begin

                    mem[word_addr] <= wdata;

                    ready <= 1'b1;

                end

                // ---------------------------------------------
                // READ OPERATION
                // ---------------------------------------------
                else begin

                    rdata <= mem[word_addr];

                    ready <= 1'b1;

                end

            end

        end

    end

endmodule
