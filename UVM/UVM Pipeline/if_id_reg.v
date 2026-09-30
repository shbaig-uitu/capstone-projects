module if_id_reg (
    clk,
    rst,
    flush,
    instruction_in,
    pc_in,
    pc_plus4_in,
    instruction_out,
    pc_out,
    pc_plus4_out
    );
    input wire clk;
    input wire rst;
    input wire flush;
    input wire [31:0] instruction_in;
    input wire [31:0] pc_in;
    input wire [31:0] pc_plus4_in;
    output reg [31:0] instruction_out;
    output reg [31:0] pc_out;
    output reg [31:0] pc_plus4_out;

    // ACTIVE HIGH RESET (posedge rst & if (rst))
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            instruction_out <= 32'b0;
            pc_out          <= 32'b0;
            pc_plus4_out    <= 32'b0;
        end
        else if (flush) begin
            instruction_out <= 32'h00000013; // NOP Instruction on flush
            pc_out          <= 32'b0;
            pc_plus4_out    <= 32'b0;
        end
        else begin
            instruction_out <= instruction_in;
            pc_out          <= pc_in;
            pc_plus4_out    <= pc_plus4_in;
        end
    end
endmodule