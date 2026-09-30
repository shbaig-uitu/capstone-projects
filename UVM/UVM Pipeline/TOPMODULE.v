module topmodule(
  result,
  rst,
  clk,
  instruct_en,
  instruction
  );

  output wire [31:0] result;
  input wire         rst;
  input wire         clk;
  input wire         instruct_en;
  input wire [31:0]  instruction;

  wire [31:0] pc;
  wire [31:0] pc_plus4;
  wire [31:0] instruction_to_pipe;

  wire [31:0] id_instruction_out;
  wire [31:0] id_pc_out;
  wire [31:0] id_pc_plus4_out;
  wire        id_reg_write;
  wire [4:0]  id_rd_addr;
  wire [4:0]  id_rs1_addr;
  wire [4:0]  id_rs2_addr;
  wire [4:0]  id_alu_op;
  wire        id_op_b_sel;
  wire [31:0] id_imm;
  wire        id_rd_sel;
  wire        id_branch;
  wire        id_jump;
  wire        id_jalr;
  wire        id_auipc;
  wire        id_mem_read;
  wire        id_mem_write;

  wire [31:0] rf_op_a;
  wire [31:0] rf_op_b;

  wire [31:0] ex_pc_out;
  wire [31:0] ex_pc_plus4_out;
  wire [31:0] ex_instruction_out;
  wire [31:0] ex_op_a_out;
  wire [31:0] ex_op_b_out;
  wire [31:0] ex_imm_out;
  wire [4:0]  ex_rd_addr_out;
  wire [4:0]  ex_rs1_addr_out;
  wire [4:0]  ex_rs2_addr_out;
  wire [4:0]  ex_alu_op_out;
  wire        ex_op_b_sel_out;
  wire        ex_mem_read_out;
  wire        ex_mem_write_out;
  wire        ex_reg_write_out;
  wire        ex_rd_sel_out;
  wire        ex_branch_out;
  wire        ex_jump_out;
  wire        ex_jalr_out;
  wire        ex_auipc_out;

  wire [31:0] alu_op_a;
  wire [31:0] alu_op_b;
  wire [31:0] ex_result;

  wire [31:0] op_a_forwarded;
  wire [31:0] op_b_forwarded;

  wire [31:0] mem_result_out;
  wire [31:0] mem_op_b_out;
  wire [4:0]  mem_rd_addr_out;
  wire [31:0] mem_pc_plus4_out;
  wire [31:0] mem_instruction_out;
  wire        mem_mem_read_out;
  wire        mem_mem_write_out;
  wire        mem_reg_write_out;
  wire        mem_rd_sel_out;
  wire        mem_jump_out;
  wire        mem_jalr_out;

  wire [31:0] wrapper_mem_o;
  wire [3:0]  store_op;
  wire [31:0] wrapper_mem_o_for_data_mem_i;

  wire [31:0] wb_result_out;
  wire [31:0] wb_wrapper_mem_o_out;
  wire [4:0]  wb_rd_addr_out;
  wire [31:0] wb_pc_plus4_out;
  wire        wb_reg_write_out;
  wire        wb_rd_sel_out;
  wire        wb_jump_out;
  wire        wb_jalr_out;

  wire [31:0] data_in_rf;
  wire        flush;


  assign instruction_to_pipe = instruct_en ? instruction : 32'h00000013;


  registerfile U_rf0(
      .rst     (rst),
      .clk     (clk),
      .en      (wb_reg_write_out),
      .data_in (data_in_rf),
      .rd_addr (wb_rd_addr_out),
      .rs1_addr(id_rs1_addr),
      .rs2_addr(id_rs2_addr),
      .op_a    (rf_op_a),
      .op_b    (rf_op_b)
  );


  if_id_reg u_if_id_reg (
    .clk            (clk),
    .rst            (rst),
    .flush          (flush),
    .instruction_in (instruction_to_pipe),
    .pc_in          (pc),
    .pc_plus4_in    (pc_plus4),
    .instruction_out(id_instruction_out),
    .pc_out         (id_pc_out),
    .pc_plus4_out   (id_pc_plus4_out)
  );


  control_unit u_cu (
      .instruction(id_instruction_out),
      .reg_write  (id_reg_write),
      .op_b_sel   (id_op_b_sel),
      .alu_op     (id_alu_op),
      .rs1_addr   (id_rs1_addr),
      .rs2_addr   (id_rs2_addr),
      .imm        (id_imm),
      .rd_addr    (id_rd_addr),
      .mem_read   (id_mem_read),
      .mem_write  (id_mem_write),
      .branch     (id_branch),
      .jump       (id_jump),
      .jalr       (id_jalr),
      .auipc      (id_auipc),
      .rd_sel     (id_rd_sel)
  );


  id_ex_reg u_id_ex_reg(
    .clk            (clk),
    .rst            (rst),
    .flush          (flush),
    .pc_in          (id_pc_out),
    .pc_plus4_in    (id_pc_plus4_out),
    .instruction_in (id_instruction_out),
    .op_a_in        (rf_op_a),
    .op_b_in        (rf_op_b),
    .imm_in         (id_imm),
    .rd_addr_in     (id_rd_addr),
    .rs1_addr_in    (id_rs1_addr),
    .rs2_addr_in    (id_rs2_addr),
    .alu_op_in      (id_alu_op),
    .op_b_sel_in    (id_op_b_sel),
    .mem_read_in    (id_mem_read),
    .mem_write_in   (id_mem_write),
    .reg_write_in   (id_reg_write),
    .rd_sel_in      (id_rd_sel),
    .branch_in      (id_branch),
    .jump_in        (id_jump),
    .jalr_in        (id_jalr),
    .auipc_in       (id_auipc),
    .pc_out         (ex_pc_out),
    .pc_plus4_out   (ex_pc_plus4_out),
    .instruction_out(ex_instruction_out),
    .op_a_out       (ex_op_a_out),
    .op_b_out       (ex_op_b_out),
    .imm_out        (ex_imm_out),
    .rd_addr_out    (ex_rd_addr_out),
    .rs1_addr_out   (ex_rs1_addr_out),
    .rs2_addr_out   (ex_rs2_addr_out),
    .alu_op_out     (ex_alu_op_out),
    .op_b_sel_out   (ex_op_b_sel_out),
    .mem_read_out   (ex_mem_read_out),
    .mem_write_out  (ex_mem_write_out),
    .reg_write_out  (ex_reg_write_out),
    .rd_sel_out     (ex_rd_sel_out),
    .branch_out     (ex_branch_out),
    .jump_out       (ex_jump_out),
    .jalr_out       (ex_jalr_out),
    .auipc_out      (ex_auipc_out)
  );


  assign op_a_forwarded =
      (mem_reg_write_out && (mem_rd_addr_out != 0) &&
       (mem_rd_addr_out == ex_rs1_addr_out)) ? mem_result_out :
      (wb_reg_write_out && (wb_rd_addr_out != 0) &&
       (wb_rd_addr_out == ex_rs1_addr_out)) ? data_in_rf :
      ex_op_a_out;


  assign op_b_forwarded =
      (mem_reg_write_out && (mem_rd_addr_out != 0) &&
       (mem_rd_addr_out == ex_rs2_addr_out)) ? mem_result_out :
      (wb_reg_write_out && (wb_rd_addr_out != 0) &&
       (wb_rd_addr_out == ex_rs2_addr_out)) ? data_in_rf :
      ex_op_b_out;


  assign alu_op_a = ex_auipc_out ? ex_pc_out : op_a_forwarded;
  assign alu_op_b = ex_op_b_sel_out ? ex_imm_out : op_b_forwarded;


  alu u_alu (
      .alu_op (ex_alu_op_out),
      .op_a   (alu_op_a),
      .op_b   (alu_op_b),
      .result (ex_result)
  );


  program_counter u_pc (
    .result  (ex_result),
    .imm     (ex_imm_out),
    .pc      (pc),
    .pc_plus4(pc_plus4),
    .branch  (ex_branch_out),
    .jump    (ex_jump_out),
    .jalr    (ex_jalr_out),
    .op_a    (op_a_forwarded),
    .rst     (rst),
    .clk     (clk)
  );


  assign flush =
      (ex_branch_out && ex_result[0]) |
      ex_jump_out |
      ex_jalr_out;


  ex_mem_reg u_ex_mem (
    .clk             (clk),
    .rst             (rst),
    .result_in       (ex_result),
    .op_b_in         (op_b_forwarded),
    .rd_addr_in      (ex_rd_addr_out),
    .pc_plus4_in     (ex_pc_plus4_out),
    .instruction_in  (ex_instruction_out),
    .mem_read_in     (ex_mem_read_out),
    .mem_write_in    (ex_mem_write_out),
    .reg_write_in    (ex_reg_write_out),
    .rd_sel_in       (ex_rd_sel_out),
    .jump_in         (ex_jump_out),
    .jalr_in         (ex_jalr_out),
    .result_out      (mem_result_out),
    .op_b_out        (mem_op_b_out),
    .rd_addr_out     (mem_rd_addr_out),
    .pc_plus4_out    (mem_pc_plus4_out),
    .instruction_out (mem_instruction_out),
    .mem_read_out    (mem_mem_read_out),
    .mem_write_out   (mem_mem_write_out),
    .reg_write_out   (mem_reg_write_out),
    .rd_sel_out      (mem_rd_sel_out),
    .jump_out        (mem_jump_out),
    .jalr_out        (mem_jalr_out)
  );


  wrapper_mem u_wm0(
    .instruction                  (mem_instruction_out),
    .mem_addr                     (mem_result_out[13:0]),
    .store_op                     (store_op),
    .wrapper_mem_o                (wrapper_mem_o),
    .wrapper_mem_i                (mem_op_b_out),
    .mem_write                    (mem_mem_write_out),
    .mem_read                     (mem_mem_read_out),
    .wrapper_mem_o_for_data_mem_i (wrapper_mem_o_for_data_mem_i),
    .clk                          (clk)
  );


  mem_wb_reg u_mem_wb(
    .clk               (clk),
    .rst               (rst),
    .result_in         (mem_result_out),
    .wrapper_mem_o_in  (wrapper_mem_o),
    .rd_addr_in        (mem_rd_addr_out),
    .pc_plus4_in       (mem_pc_plus4_out),
    .reg_write_in      (mem_reg_write_out),
    .rd_sel_in         (mem_rd_sel_out),
    .jump_in           (mem_jump_out),
    .jalr_in           (mem_jalr_out),
    .result_out        (wb_result_out),
    .wrapper_mem_o_out (wb_wrapper_mem_o_out),
    .rd_addr_out       (wb_rd_addr_out),
    .pc_plus4_out      (wb_pc_plus4_out),
    .reg_write_out     (wb_reg_write_out),
    .rd_sel_out        (wb_rd_sel_out),
    .jump_out          (wb_jump_out),
    .jalr_out          (wb_jalr_out)
  );


  assign data_in_rf =
      (wb_jump_out | wb_jalr_out) ? wb_pc_plus4_out :
      (wb_rd_sel_out ? wb_result_out : wb_wrapper_mem_o_out);
assign result = data_in_rf;

endmodule