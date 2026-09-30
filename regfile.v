`include "rv32i_soc_defines.v"

module regfile (
    input  wire        clk,
    input  wire        rst_n,
    input  wire         we,
    input  wire  [4:0]  rs1_addr,
    input  wire  [4:0]  rs2_addr,
    input  wire  [4:0]  rd_addr,
    input  wire  [31:0] rd_data,
    output wire  [31:0] rs1_data,
    output wire  [31:0] rs2_data
);

    reg [31:0] regs [0:31];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'h0000_0000;
            end
        end else begin
            if (we && (rd_addr != 5'd0)) begin
                regs[rd_addr] <= rd_data;
            end
        end
    end

    assign rs1_data = (rs1_addr == 5'd0) ? 32'h0000_0000 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'h0000_0000 : regs[rs2_addr];

endmodule
