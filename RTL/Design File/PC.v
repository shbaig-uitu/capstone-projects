
module program_counter (
    result,
    imm,
    pc,
    pc_plus4,
    branch,
    jump,
    jalr,
    op_a,
    rst,
    clk 
);
    input wire                   rst;
    input wire                branch;
    input wire                  jump;
    input wire                  jalr;
    input wire                   clk;
    output reg [31:0]             pc;
    output reg [31:0]       pc_plus4;
    input wire [31:0]            imm;
    input wire [31:0]         result;
    input wire [31:0]          op_a;
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        pc <= 0;
        pc_plus4 <= 0;
    end 
    else if(jalr) begin
        pc <= op_a + imm;
        pc_plus4 <= pc + 32'd4;
    end
    else if(jump || (branch && result[0]))  begin 
        pc <= pc + imm;
        pc_plus4 <= pc + 32'd4;
    end
    else begin
        pc <= pc + 32'd4;
        pc_plus4 <= pc + 32'd4;
    end
end
endmodule
