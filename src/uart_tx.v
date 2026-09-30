module uart_tx #(parameter CLKS_PER_BIT = 217) (
    input  clk, rst,
    input  tx_en,
    input  [7:0] tx_data,
    output reg tx_pin,
    output reg tx_busy
);
    localparam IDLE=0, START=1, DATA=2, STOP=3;
    reg [1:0] state;
    reg [7:0] data_reg;
    reg [15:0] clk_count;
    reg [2:0] bit_index;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE; tx_pin <= 1; tx_busy <= 0;
            clk_count <= 0; bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_pin <= 1;
                    if (tx_en) begin
                        tx_busy <= 1; data_reg <= tx_data;
                        state <= START; clk_count <= 0;
                    end else tx_busy <= 0;
                end
                START: begin
                    tx_pin <= 0;
                    if (clk_count < CLKS_PER_BIT-1) clk_count <= clk_count + 1;
                    else begin clk_count <= 0; state <= DATA; bit_index <= 0; end
                end
                DATA: begin
                    tx_pin <= data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT-1) clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        if (bit_index < 7) bit_index <= bit_index + 1;
                        else state <= STOP;
                    end
                end
                STOP: begin
                    tx_pin <= 1;
                    if (clk_count < CLKS_PER_BIT-1) clk_count <= clk_count + 1;
                    else begin clk_count <= 0; state <= IDLE; end
                end
            endcase
        end
    end
endmodule
