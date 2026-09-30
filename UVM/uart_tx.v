module uart_tx(
    input clk,
    input reset,
    input send,
    input [7:0] data_in,
    output reg tx_line,
    output reg busy
);

parameter CLKS_PER_BIT = 8;

parameter IDLE   = 3'd0;
parameter START  = 3'd1;
parameter DATA   = 3'd2;
parameter PARITY = 3'd3;
parameter STOP   = 3'd4;

reg [2:0] state;
reg [2:0] bit_index;
reg [7:0] data_reg;
reg parity_reg;

wire tick;

baud_gen #(.CLKS_PER_BIT(CLKS_PER_BIT)) bg (
    .clk(clk),
    .reset(reset),
    .enable(busy),
    .half(1'b0),
    .tick(tick)
);

always @(posedge clk) begin
    if (reset) begin
        state <= IDLE;
        tx_line <= 1'b1;
        busy <= 1'b0;
        bit_index <= 0;
    end
    else begin
        case (state)

            IDLE: begin
                tx_line <= 1'b1;
                busy <= 1'b0;
                bit_index <= 0;
                if (send) begin
                    data_reg <= data_in;
                    parity_reg <= ^data_in;
                    busy <= 1'b1;
                    state <= START;
                end
            end

            START: begin
                tx_line <= 1'b0;
                if (tick)
                    state <= DATA;
            end

            DATA: begin
                tx_line <= data_reg[bit_index];
                if (tick) begin
                    if (bit_index == 3'd7) begin
                        bit_index <= 0;
                        state <= PARITY;
                    end
                    else
                        bit_index <= bit_index + 1'b1;
                end
            end

            PARITY: begin
                tx_line <= parity_reg;
                if (tick)
                    state <= STOP;
            end

            STOP: begin
                tx_line <= 1'b1;
                if (tick) begin
                    busy <= 1'b0;
                    state <= IDLE;
                end
            end

            default: state <= IDLE;

        endcase
    end
end

endmodule
