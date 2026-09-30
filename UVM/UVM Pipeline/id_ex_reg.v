module id_ex_reg (
    clk, rst, flush, pc_in, pc_plus4_in, instruction_in, op_a_in, op_b_in, imm_in,
    rd_addr_in, rs1_addr_in, rs2_addr_in, alu_op_in, op_b_sel_in, mem_read_in,
    mem_write_in, reg_write_in, rd_sel_in, branch_in, jump_in, jalr_in, auipc_in,
    pc_out, pc_plus4_out, instruction_out, op_a_out, op_b_out, imm_out,
    rd_addr_out, rs1_addr_out, rs2_addr_out, alu_op_out, op_b_sel_out, mem_read_out,
    mem_write_out, reg_write_out, rd_sel_out, branch_out, jump_out, jalr_out, auipc_out
    );
    input wire clk, rst, flush;
    input wire [31:0] pc_in, pc_plus4_in, instruction_in, op_a_in, op_b_in, imm_in;
    input wire [4:0]  rd_addr_in, rs1_addr_in, rs2_addr_in, alu_op_in;
    input wire        op_b_sel_in, mem_read_in, mem_write_in, reg_write_in, rd_sel_in, branch_in, jump_in, jalr_in, auipc_in;

    output reg [31:0] pc_out, pc_plus4_out, instruction_out, op_a_out, op_b_out, imm_out;
    output reg [4:0]  rd_addr_out, rs1_addr_out, rs2_addr_out, alu_op_out;
    output reg        op_b_sel_out, mem_read_out, mem_write_out, reg_write_out, rd_sel_out, branch_out, jump_out, jalr_out, auipc_out;

    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            pc_out <= 32'b0; pc_plus4_out <= 32'b0; instruction_out <= 32'b0;
            op_a_out <= 32'b0; op_b_out <= 32'b0; imm_out <= 32'b0;
            rd_addr_out <= 5'b0; rs1_addr_out <= 5'b0; rs2_addr_out <= 5'b0; alu_op_out <= 5'b0;
            op_b_sel_out <= 1'b0; mem_read_out <= 1'b0; mem_write_out <= 1'b0; reg_write_out <= 1'b0;
            rd_sel_out <= 1'b0; branch_out <= 1'b0; jump_out <= 1'b0; jalr_out <= 1'b0; auipc_out <= 1'b0;
        end else begin
            pc_out <= pc_in; pc_plus4_out <= pc_plus4_in; instruction_out <= instruction_in;
            op_a_out <= op_a_in; op_b_out <= op_b_in; imm_out <= imm_in;
            rd_addr_out <= rd_addr_in; rs1_addr_out <= rs1_addr_in; rs2_addr_out <= rs2_addr_in; alu_op_out <= alu_op_in;
            op_b_sel_out <= op_b_sel_in; mem_read_out <= mem_read_in; mem_write_out <= mem_write_in; reg_write_out <= reg_write_in;
            rd_sel_out <= rd_sel_in; branch_out <= branch_in; jump_out <= jump_in; jalr_out <= jalr_in; auipc_out <= auipc_in;
        end
    end
endmodule
