`include "rv32i_soc_defines.v"

module ic_mailbox (
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

    output wire         c0_to_c1_flag,
    output wire         c1_to_c0_flag
);

    reg [31:0] c0_to_c1_data;
    reg        c0_to_c1_flag_r;
    reg [31:0] c1_to_c0_data;
    reg        c1_to_c0_flag_r;

    wire [31:0] word_addr = haddr & 32'hFFFF_FFFC;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c0_to_c1_data   <= 32'h0000_0000;
            c0_to_c1_flag_r <= 1'b0;
            c1_to_c0_data   <= 32'h0000_0000;
            c1_to_c0_flag_r <= 1'b0;
        end else if (hvalid && hwrite) begin
            case (word_addr)
                `MBOX_C0_TO_C1_DATA: c0_to_c1_data   <= hwdata;
                `MBOX_C0_TO_C1_FLAG: c0_to_c1_flag_r <= hwdata[0];
                `MBOX_C1_TO_C0_DATA: c1_to_c0_data   <= hwdata;
                `MBOX_C1_TO_C0_FLAG: c1_to_c0_flag_r <= hwdata[0];
                default: begin
                end
            endcase
        end
    end

    always @(*) begin
        case (word_addr)
            `MBOX_C0_TO_C1_DATA: hrdata = c0_to_c1_data;
            `MBOX_C0_TO_C1_FLAG: hrdata = {31'h0000_0000, c0_to_c1_flag_r};
            `MBOX_C1_TO_C0_DATA: hrdata = c1_to_c0_data;
            `MBOX_C1_TO_C0_FLAG: hrdata = {31'h0000_0000, c1_to_c0_flag_r};
            default:             hrdata = 32'h0000_0000;
        endcase
    end

    assign hready = 1'b1;
    assign hresp  = `HRESP_OKAY;

    assign c0_to_c1_flag = c0_to_c1_flag_r;
    assign c1_to_c0_flag = c1_to_c0_flag_r;

endmodule
