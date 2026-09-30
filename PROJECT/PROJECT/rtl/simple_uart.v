`timescale 1ns/1ps

module simple_uart (

    input  wire        clk,
    input  wire        rst,

    // Request from Interconnect
    input  wire        req,
    input  wire        write_en,

    input  wire [31:0] addr,
    input  wire [31:0] wdata,

    // Read Data
    output reg  [31:0] rdata,

    // Response
    output reg         ready,
    output reg         error,

    // UART Output
    output reg  [7:0]  uart_tx_data,
    output reg         uart_tx_valid

);

    // =====================================================
    // UART MEMORY MAP
    //
    // 0x3000_0000 ? UART TX DATA
    // 0x3000_0004 ? UART STATUS
    //
    // STATUS:
    // bit 0 = UART Ready
    // =====================================================

    always @(posedge clk) begin

        if (rst) begin

            rdata         <= 32'b0;
            ready         <= 1'b0;
            error         <= 1'b0;

            uart_tx_data  <= 8'b0;
            uart_tx_valid <= 1'b0;

        end

        else begin

            // Default values
            ready         <= 1'b0;
            error         <= 1'b0;

            // TX valid normally low
            uart_tx_valid <= 1'b0;

            if (req) begin

                case (addr)

                    // =====================================
                    // UART TRANSMIT DATA REGISTER
                    // =====================================
                    32'h3000_0000: begin

                        if (write_en) begin

                            uart_tx_data  <= wdata[7:0];
                            uart_tx_valid <= 1'b1;

                            ready <= 1'b1;

                        end

                        else begin

                            rdata <= {
                                24'b0,
                                uart_tx_data
                            };

                            ready <= 1'b1;

                        end

                    end


                    // =====================================
                    // UART STATUS REGISTER
                    // =====================================
                    32'h3000_0004: begin

                        if (!write_en) begin

                            // UART always ready in this
                            // simplified implementation
                            rdata <= 32'h00000001;

                            ready <= 1'b1;

                        end

                        else begin

                            // Writing to status is invalid
                            rdata <= 32'b0;
                            ready <= 1'b1;
                            error <= 1'b1;

                        end

                    end


                    // =====================================
                    // INVALID ADDRESS
                    // =====================================
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
