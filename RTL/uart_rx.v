module uart_rx (
    input clk,
    input reset,
    input rx_line,
    output reg [7:0] rx_data,
    output reg rx_done,
    output reg parity_err,
    output reg frame_err
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
reg parity_bad;

reg rx_ff1, rx_sync;
always @(posedge clk) begin
    if (reset) begin
        rx_ff1 <= 1'b1;
        rx_sync <= 1'b1;
    end
    else begin
        rx_ff1 <= rx_line;
        rx_sync <= rx_ff1;
    end
end

wire tick;
wire baud_enable = (state != IDLE);
wire baud_half   = (state == START);

baud_gen #(.CLKS_PER_BIT(CLKS_PER_BIT)) bg (
    .clk(clk),
    .reset(reset),
    .enable(baud_enable),
    .half(baud_half),
    .tick(tick)
);

always @(posedge clk) begin
    if (reset) begin
        state <= IDLE;
        bit_index <= 0;
        rx_done <= 1'b0;
        parity_err <= 1'b0;
        frame_err <= 1'b0;
        parity_bad <= 1'b0;
    end
    else begin
        rx_done <= 1'b0;
        parity_err <= 1'b0;
        frame_err <= 1'b0;

        case (state)

            IDLE: begin
                if (rx_sync == 1'b0)
                    state <= START;
            end

            START: begin
                if (tick) begin
                    if (rx_sync == 1'b0) begin
                        bit_index <= 0;
                        state <= DATA;
                    end
                    else
                        state <= IDLE;
                end
            end

            DATA: begin
                if (tick) begin
                    data_reg[bit_index] <= rx_sync;
                    if (bit_index == 3'd7)
                        state <= PARITY;
                    else
                        bit_index <= bit_index + 1'b1;
                end
            end

            PARITY: begin
                if (tick) begin
                    parity_bad <= (rx_sync != ^data_reg);
                    state <= STOP;
                end
            end

            STOP: begin
                if (tick) begin
                    rx_data <= data_reg;
                    rx_done <= 1'b1;
                    parity_err <= parity_bad;
                    frame_err <= (rx_sync != 1'b1);
                    state <= IDLE;
                end
            end

            default: state <= IDLE;

        endcase
    end
end
endmodule

