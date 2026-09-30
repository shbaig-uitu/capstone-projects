`include "rv32i_soc_defines.v"

module shared_dmem #(
    parameter DEPTH = 2048
) (
    input  wire        clk,
    input  wire        rst_n,

    input  wire [31:0] haddr,
    input  wire         hwrite,
    input  wire [1:0]  hsize,
    input  wire [31:0] hwdata,
    input  wire         hvalid,

    output wire [31:0] hrdata,
    output wire         hready,
    output wire         hresp
);

    reg [31:0] mem [0:DEPTH-1];
    integer i;

    wire [31:0] word_index = (haddr - `DMEM_BASE) >> 2;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            mem[i] = 32'h0000_0000;
        end
    end

    always @(posedge clk) begin
        if (hvalid && hwrite) begin
            case (hsize)
                `HSIZE_BYTE: begin
                    case (haddr[1:0])
                        2'b00: mem[word_index][7:0]   <= hwdata[7:0];
                        2'b01: mem[word_index][15:8]  <= hwdata[15:8];
                        2'b10: mem[word_index][23:16] <= hwdata[23:16];
                        2'b11: mem[word_index][31:24] <= hwdata[31:24];
                    endcase
                end
                `HSIZE_HALF: begin
                    case (haddr[1])
                        1'b0: mem[word_index][15:0]  <= hwdata[15:0];
                        1'b1: mem[word_index][31:16] <= hwdata[31:16];
                    endcase
                end
                default: begin
                    mem[word_index] <= hwdata;
                end
            endcase
        end
    end

    assign hrdata = mem[word_index];
    assign hready = 1'b1;
    assign hresp  = `HRESP_OKAY;

endmodule
