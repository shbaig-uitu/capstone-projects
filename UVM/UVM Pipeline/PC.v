module program_counter (
    result, imm, pc, pc_plus4, branch, jump, jalr, op_a, rst, clk 
);
    input wire        rst, branch, jump, jalr, clk;
    output reg [31:0] pc, pc_plus4;
    input wire [31:0] imm, result, op_a;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0;
            pc_plus4 <= 32'b0;
        end else if (jalr) begin
            pc <= op_a + imm;
            pc_plus4 <= pc + 32'd4;
        end else if (jump || (branch && result[0])) begin 
            pc <= pc + imm;
            pc_plus4 <= pc + 32'd4;
        end else begin
            pc <= pc + 32'd4;
            pc_plus4 <= pc + 32'd4;
        end
    end
endmodule