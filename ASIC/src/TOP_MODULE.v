module topmodule(
  result,
  rst,
  clk,
  instruct_en,
  shared_addr,
  shared_read,
  shared_write,
  shared_wdata,
  shared_wmask,
  shared_rdata
  );
  output wire[31:0]                result;
  input wire                          rst;
  input wire                          clk;
  input wire                  instruct_en;
  wire[31:0]                  instruction;
  wire[31:0]                           pc;
  wire[31:0]                     pc_plus4;
  wire                          reg_write;
  wire[4:0]                       rd_addr;
  wire[4:0]                      rs1_addr;
  wire[4:0]                      rs2_addr;
  wire[4:0]                        alu_op;
  wire[31:0]                     rf_op_a;
  wire[31:0]                    alu_op_a;
  wire[31:0]                         op_b;
  wire[31:0]                     alu_op_b;
  wire                           op_b_sel; 
  wire[31:0]                          imm;
  wire[31:0]                data_in_rf;
  wire                             rd_sel;
  wire[3:0]                      store_op;
  wire                             branch;
  wire                              jump;
  wire                              jalr;
  wire                             auipc;
wire[31:0]                wrapper_mem_o_for_cache_i;
  wire[31:0]                wrapper_mem_o;
  wire                          mem_read;
  wire                         mem_write;

  // shared-memory bus -- goes up to soc_top
  output wire [3:0]           shared_addr;
  output wire                 shared_read;
  output wire                 shared_write;
  output wire [31:0]          shared_wdata;
  output wire [3:0]           shared_wmask;
  input  wire [31:0]          shared_rdata;

  registerfile U_rf0(
      .rst     (       rst),
      .clk     (       clk),
      .en      ( reg_write),
      .data_in (data_in_rf),
      .rd_addr (   rd_addr),
      .rs1_addr(  rs1_addr),
      .rs2_addr(  rs2_addr),
      .op_a    (   rf_op_a),
      .op_b    (      op_b)
  );

  assign alu_op_a = auipc ? pc : rf_op_a;
  assign alu_op_b = op_b_sel ? imm : op_b;

  alu u_alu (
      .alu_op  (    alu_op),
      .op_a    ( alu_op_a),
      .op_b    ( alu_op_b),
      .result  (    result)
    );

 program_counter u_pc (
    .result  ( result),
    .imm     (    imm),
    .pc      (     pc),
    .pc_plus4(pc_plus4),
    .branch  ( branch),
    .jump    (   jump),
    .jalr    (   jalr),
    .op_a    (rf_op_a),
    .rst     (    rst),
    .clk     (    clk) 
);

    instruct_mem u_ir0(
      .addr_instr_mem (            pc[8:2]),
      .instruction    (        instruction),
      .instruct_en    (        instruct_en),
      .clk            (                clk)
      );

    control_unit u_cu (
      .instruction(instruction),
      .reg_write  (  reg_write),
      .op_b_sel   (   op_b_sel),
      .alu_op     (     alu_op),
      .rs1_addr   (   rs1_addr),
      .rs2_addr   (   rs2_addr),
      .imm        (        imm),
      .rd_addr    (    rd_addr),
      .mem_read   (   mem_read),
      .mem_write  (  mem_write),
      .branch     (     branch),
      .jump       (       jump),
      .jalr       (       jalr),
      .auipc      (      auipc),
      .rd_sel     (     rd_sel)
    );

  wrapper_mem  u_wm0(
    .instruction                 (                 instruction),
    .mem_addr                    (                result[13:0]),
    .store_op                    (                    store_op),
    .wrapper_mem_o               (               wrapper_mem_o),
    .wrapper_mem_i               (                        op_b),
    .mem_write                   (                   mem_write),
    .mem_read                    (                    mem_read),
    .wrapper_mem_o_for_cache_i   (   wrapper_mem_o_for_cache_i),
    .clk                         (                         clk),
    .shared_addr                 (                 shared_addr),
    .shared_read                 (                 shared_read),
    .shared_write                (                shared_write),
    .shared_wdata                (                shared_wdata),
    .shared_wmask                (                shared_wmask),
    .shared_rdata                (                shared_rdata)
);
    
    assign data_in_rf = (jump | jalr) ? pc_plus4 : (rd_sel ? result : wrapper_mem_o);
endmodule
