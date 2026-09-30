`timescale 1ns/1ps

module ahb_lite_adapter (

    input  wire        clk,
    input  wire        rst,

    // =====================================================
    // RV32I CORE MEMORY INTERFACE
    // =====================================================
    input  wire        core_req,
    input  wire        core_write,
    input  wire [31:0] core_addr,
    input  wire [31:0] core_wdata,
    input  wire [3:0]  core_be,

    output reg  [31:0] core_rdata,
    output reg         core_ready,
    output reg         core_error,

    // =====================================================
    // AHB-LITE STYLE MASTER INTERFACE
    // =====================================================
    output reg  [31:0] HADDR,
    output reg  [31:0] HWDATA,
    output reg         HWRITE,
    output reg  [2:0]  HSIZE,
    output reg  [1:0]  HTRANS,

    input  wire [31:0] HRDATA,
    input  wire        HREADY,
    input  wire        HRESP
);

    localparam HTRANS_IDLE   = 2'b00;
    localparam HTRANS_NONSEQ = 2'b10;

    localparam IDLE     = 1'b0;
    localparam TRANSFER = 1'b1;

    reg state;

    // =====================================================
    // BYTE ENABLE ? AHB SIZE
    // =====================================================
    always @(*) begin

        case (core_be)

            4'b0001: HSIZE = 3'b000; // Byte
            4'b0010: HSIZE = 3'b000;
            4'b0100: HSIZE = 3'b000;
            4'b1000: HSIZE = 3'b000;

            4'b0011: HSIZE = 3'b001; // Half-word
            4'b1100: HSIZE = 3'b001;

            default: HSIZE = 3'b010; // Word

        endcase

    end


    // =====================================================
    // AHB ADAPTER FSM
    // =====================================================
    always @(posedge clk) begin

        if (rst) begin

            state      <= IDLE;

            HADDR      <= 32'b0;
            HWDATA     <= 32'b0;
            HWRITE     <= 1'b0;
            HTRANS     <= HTRANS_IDLE;

            core_rdata <= 32'b0;
            core_ready <= 1'b0;
            core_error <= 1'b0;

        end

        else begin

            core_ready <= 1'b0;
            core_error <= 1'b0;

            case (state)

                IDLE: begin

                    HTRANS <= HTRANS_IDLE;

                    if (core_req) begin

                        HADDR  <= core_addr;
                        HWDATA <= core_wdata;
                        HWRITE <= core_write;

                        HTRANS <= HTRANS_NONSEQ;

                        state <= TRANSFER;

                    end

                end


                TRANSFER: begin

                    if (HREADY) begin

                        if (!HWRITE)
                            core_rdata <= HRDATA;

                        core_ready <= 1'b1;
                        core_error <= HRESP;

                        HTRANS <= HTRANS_IDLE;

                        state <= IDLE;

                    end

                end

            endcase

        end

    end

endmodule
