`include "rv32i_soc_defines.v"

module uart_peripheral #(
    parameter CLKS_PER_BIT = 434
) (
    input  wire        clk,
    input  wire        rst_n,

    input  wire [31:0] haddr,
    input  wire         hwrite,
    input  wire [1:0]  hsize,
    input  wire [31:0] hwdata,
    input  wire         hvalid,

    output reg  [31:0] hrdata,
    output wire         hready,
    output wire         hresp,

    output reg          uart_tx
);

    localparam S_IDLE  = 2'b00;
    localparam S_START = 2'b01;
    localparam S_DATA  = 2'b10;
    localparam S_STOP  = 2'b11;

    reg [1:0]  state;
    reg [7:0]  tx_shift;
    reg [15:0] clk_cnt;
    reg [2:0]  bit_idx;
    reg        tx_busy;

    wire [31:0] word_addr = haddr & 32'hFFFF_FFFC;
    wire        wr_txdata = hvalid & hwrite & (word_addr == `UART_TXDATA);
    wire        load_pulse = wr_txdata & ~tx_busy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S_IDLE;
            tx_shift <= 8'h00;
            clk_cnt  <= 16'h0000;
            bit_idx  <= 3'd0;
            tx_busy  <= 1'b0;
            uart_tx  <= 1'b1;
        end else begin
            case (state)
                S_IDLE: begin
                    uart_tx <= 1'b1;
                    if (load_pulse) begin
                        tx_shift <= hwdata[7:0];
                        tx_busy  <= 1'b1;
                        clk_cnt  <= 16'h0000;
                        bit_idx  <= 3'd0;
                        state    <= S_START;
                    end
                end

                S_START: begin
                    uart_tx <= 1'b0;
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 16'h0000;
                        state   <= S_DATA;
                    end else begin
                        clk_cnt <= clk_cnt + 16'h0001;
                    end
                end

                S_DATA: begin
                    uart_tx <= tx_shift[bit_idx];
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 16'h0000;
                        if (bit_idx == 3'd7) begin
                            state <= S_STOP;
                        end else begin
                            bit_idx <= bit_idx + 3'd1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 16'h0001;
                    end
                end

                S_STOP: begin
                    uart_tx <= 1'b1;
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 16'h0000;
                        tx_busy <= 1'b0;
                        state   <= S_IDLE;
                    end else begin
                        clk_cnt <= clk_cnt + 16'h0001;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

    always @(*) begin
        case (word_addr)
            `UART_TXDATA: hrdata = {24'h00_0000, tx_shift};
            `UART_STATUS: hrdata = {31'h0000_0000, tx_busy};
            default:      hrdata = 32'h0000_0000;
        endcase
    end

    assign hready = 1'b1;
    assign hresp  = `HRESP_OKAY;

endmodule
