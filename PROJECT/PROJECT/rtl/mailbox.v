`timescale 1ns/1ps

module mailbox_unit (

    input  wire        clk,
    input  wire        rst,

    // =========================================================
    // REQUEST FROM INTERCONNECT
    // =========================================================
    input  wire        req,
    input  wire        write_en,

    input  wire [31:0] addr,
    input  wire [31:0] wdata,

    // =========================================================
    // RESPONSE
    // =========================================================
    output reg  [31:0] rdata,
    output reg         ready,
    output reg         error

);

    // =========================================================
    // MAILBOX REGISTERS
    //
    // mailbox_0_to_1:
    // Core 0 sends data to Core 1
    //
    // mailbox_1_to_0:
    // Core 1 sends data to Core 0
    // =========================================================

    reg [31:0] mailbox_0_to_1;
    reg [31:0] mailbox_1_to_0;

    // =========================================================
    // STATUS FLAGS
    //
    // bit = 1 ? New message available
    // bit = 0 ? No new message
    // =========================================================

    reg valid_0_to_1;
    reg valid_1_to_0;


    // =========================================================
    // MAILBOX ADDRESS MAP
    //
    // 0x1000_0000 ? Core 0 ? Core 1 DATA
    // 0x1000_0004 ? Core 1 ? Core 0 DATA
    // 0x1000_0008 ? STATUS
    //
    // STATUS:
    //
    // bit 0 ? valid_0_to_1
    // bit 1 ? valid_1_to_0
    // =========================================================


    always @(posedge clk) begin

        if (rst) begin

            mailbox_0_to_1 <= 32'b0;
            mailbox_1_to_0 <= 32'b0;

            valid_0_to_1 <= 1'b0;
            valid_1_to_0 <= 1'b0;

            rdata <= 32'b0;
            ready <= 1'b0;
            error <= 1'b0;

        end

        else begin

            // Default response
            ready <= 1'b0;
            error <= 1'b0;


            if (req) begin

                // =================================================
                // WRITE OPERATION
                // =================================================

                if (write_en) begin

                    case (addr)

                        // -----------------------------------------
                        // Core 0 ? Core 1
                        // -----------------------------------------

                        32'h1000_0000: begin

                            mailbox_0_to_1 <= wdata;
                            valid_0_to_1 <= 1'b1;

                            ready <= 1'b1;

                        end


                        // -----------------------------------------
                        // Core 1 ? Core 0
                        // -----------------------------------------

                        32'h1000_0004: begin

                            mailbox_1_to_0 <= wdata;
                            valid_1_to_0 <= 1'b1;

                            ready <= 1'b1;

                        end


                        // -----------------------------------------
                        // Clear Status Flags
                        //
                        // Writing:
                        //
                        // bit 0 = 1 ? clear Core0?Core1 flag
                        // bit 1 = 1 ? clear Core1?Core0 flag
                        // -----------------------------------------

                        32'h1000_0008: begin

                            if (wdata[0])
                                valid_0_to_1 <= 1'b0;

                            if (wdata[1])
                                valid_1_to_0 <= 1'b0;

                            ready <= 1'b1;

                        end


                        // Invalid mailbox address
                        default: begin

                            error <= 1'b1;
                            ready <= 1'b1;

                        end

                    endcase

                end


                // =================================================
                // READ OPERATION
                // =================================================

                else begin

                    case (addr)

                        // -----------------------------------------
                        // Read Core0 ? Core1 mailbox
                        // -----------------------------------------

                        32'h1000_0000: begin

                            rdata <= mailbox_0_to_1;
                            ready <= 1'b1;

                        end


                        // -----------------------------------------
                        // Read Core1 ? Core0 mailbox
                        // -----------------------------------------

                        32'h1000_0004: begin

                            rdata <= mailbox_1_to_0;
                            ready <= 1'b1;

                        end


                        // -----------------------------------------
                        // Read Status
                        // -----------------------------------------

                        32'h1000_0008: begin

                            rdata <= {
                                30'b0,
                                valid_1_to_0,
                                valid_0_to_1
                            };

                            ready <= 1'b1;

                        end


                        // Invalid address
                        default: begin

                            rdata <= 32'b0;
                            error <= 1'b1;
                            ready <= 1'b1;

                        end

                    endcase

                end

            end

        end

    end

endmodule
