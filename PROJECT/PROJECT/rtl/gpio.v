`timescale 1ns/1ps

module gpio (

    input  wire        clk,
    input  wire        rst,

    // Request from interconnect
    input  wire        req,
    input  wire        write_en,

    // Address and write data
    input  wire [31:0] addr,
    input  wire [31:0] wdata,

    // Read data
    output reg  [31:0] rdata,

    // Response signals
    output reg         ready,
    output reg         error,

    // Physical GPIO output
    output reg  [31:0] gpio_out

);

    // GPIO address:
    // 0x2000_0000 ? GPIO DATA register

    always @(posedge clk) begin

        if (rst) begin

            gpio_out <= 32'b0;
            rdata    <= 32'b0;
            ready    <= 1'b0;
            error    <= 1'b0;

        end

        else begin

            // Default values
            ready <= 1'b0;
            error <= 1'b0;

            if (req) begin

                case (addr)

                    // =========================================
                    // GPIO DATA REGISTER
                    // =========================================
                    32'h2000_0000: begin

                        // WRITE
                        if (write_en) begin

                            gpio_out <= wdata;
                            ready    <= 1'b1;

                        end

                        // READ
                        else begin

                            rdata <= gpio_out;
                            ready <= 1'b1;

                        end

                    end


                    // =========================================
                    // INVALID GPIO ADDRESS
                    // =========================================
                    default: begin

                        rdata <= 32'b0;
                        ready <= 1'b1;
                        error <= 1'b1;

                    end

                endcase

            end

        end

    end

endmodule
