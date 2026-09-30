`include "rv32i_soc_defines.v"

module gpio_peripheral (
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

    output wire [7:0]  led
);

    reg [31:0] led_reg;

    wire [31:0] word_addr = haddr & 32'hFFFF_FFFC;
    wire        wr_led = hvalid & hwrite & (word_addr == `GPIO_LED);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_reg <= 32'h0000_0000;
        end else if (wr_led) begin
            led_reg <= hwdata;
        end
    end

    always @(*) begin
        case (word_addr)
            `GPIO_LED: hrdata = led_reg;
            default:   hrdata = 32'h0000_0000;
        endcase
    end

    assign led    = led_reg[7:0];
    assign hready = 1'b1;
    assign hresp  = `HRESP_OKAY;

endmodule
