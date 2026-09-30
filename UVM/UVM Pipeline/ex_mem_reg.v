module ex_mem_reg (
    clk, rst, result_in, op_b_in, rd_addr_in, pc_plus4_in, instruction_in,
    mem_read_in, mem_write_in, reg_write_in, rd_sel_in, jump_in, jalr_in,
    result_out, op_b_out, rd_addr_out, pc_plus4_out, instruction_out,
    mem_read_out, mem_write_out, reg_write_out, rd_sel_out, jump_out, jalr_out
    );
    input wire clk, rst;
    input wire [31:0] result_in, op_b_in, pc_plus4_in, instruction_in;
    input wire [4:0]  rd_addr_in;
    input wire        mem_read_in, mem_write_in, reg_write_in, rd_sel_in, jump_in, jalr_in;

    output reg [31:0] result_out, op_b_out, pc_plus4_out, instruction_out;
    output reg [4:0]  rd_addr_out;
    output reg        mem_read_out, mem_write_out, reg_write_out, rd_sel_out, jump_out, jalr_out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result_out <= 32'b0; op_b_out <= 32'b0; rd_addr_out <= 5'b0;
            pc_plus4_out <= 32'b0; instruction_out <= 32'b0; mem_read_out <= 1'b0;
            mem_write_out <= 1'b0; reg_write_out <= 1'b0; rd_sel_out <= 1'b0;
            jump_out <= 1'b0; jalr_out <= 1'b0;
        end else begin
            result_out <= result_in; op_b_out <= op_b_in; rd_addr_out <= rd_addr_in;
            pc_plus4_out <= pc_plus4_in; instruction_out <= instruction_in; mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in; reg_write_out <= reg_write_in; rd_sel_out <= rd_sel_in;
            jump_out <= jump_in; jalr_out <= jalr_in;
        end
    end
endmodule
