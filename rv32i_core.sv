// =============================================================
// rv32i_core.sv
// Multicycle RV32I core.
//
// Implements: R-type ALU ops, I-type ALU ops, LW, SW, all six
// branches, JAL, JALR, LUI, AUIPC.
// NOT implemented (out of scope for this project): LB/LH/LBU/LHU/SB/SH,
// FENCE, ECALL/EBREAK, CSR instructions, M-extension.
//
// Instruction fetch uses the PHYSICAL instruction memory directly
// (untranslated) - see docs/architecture.md Section 1.
// LW/SW addresses are virtual and go through the MMU interface.
// =============================================================
import soc_pkg::*;

module rv32i_core (
  input  logic         clk,
  input  logic         rst_n,

  // ---- instruction memory (physical, untranslated) ----------------------
  output logic [IMEM_ADDR_BITS-1:0] imem_addr,
  input  logic [31:0]               imem_rdata,

  // ---- data side, goes to MMU (virtual) --------------------------------
  output logic [VA_WIDTH-1:0]  dmem_va,
  output logic                 dmem_re,
  output logic                 dmem_we,
  output logic [31:0]          dmem_wdata,
  input  logic [31:0]          dmem_rdata,
  input  logic                 dmem_ready
);

  // ---- program counter ---------------------------------------------------
  logic [31:0] pc, pc_n;
  logic [31:0] ir;

  // ---- register file -----------------------------------------------------
  logic [31:0] regfile [32];
  logic [4:0]  rs1, rs2, rd;
  logic [31:0] rs1_data, rs2_data;
  logic        reg_we;
  logic [31:0] reg_wdata;

  assign rs1 = ir[19:15];
  assign rs2 = ir[24:20];
  assign rd  = ir[11:7];

  assign rs1_data = (rs1 == 5'd0) ? 32'h0 : regfile[rs1];
  assign rs2_data = (rs2 == 5'd0) ? 32'h0 : regfile[rs2];

  always_ff @(posedge clk) begin
    if (reg_we && rd != 5'd0) regfile[rd] <= reg_wdata;
  end

  // ---- instruction fields --------------------------------------------
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;
  assign opcode = ir[6:0];
  assign funct3 = ir[14:12];
  assign funct7 = ir[31:25];

  // ---- immediates ------------------------------------------------------
  logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
  assign imm_i = {{20{ir[31]}}, ir[31:20]};
  assign imm_s = {{20{ir[31]}}, ir[31:25], ir[11:7]};
  assign imm_b = {{19{ir[31]}}, ir[31], ir[7], ir[30:25], ir[11:8], 1'b0};
  assign imm_u = {ir[31:12], 12'h0};
  assign imm_j = {{11{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21], 1'b0};

  // ---- opcode groups -----------------------------------------------------
  localparam logic [6:0] OP_RTYPE  = 7'b0110011;
  localparam logic [6:0] OP_ITYPE  = 7'b0010011;
  localparam logic [6:0] OP_LOAD   = 7'b0000011;
  localparam logic [6:0] OP_STORE  = 7'b0100011;
  localparam logic [6:0] OP_BRANCH = 7'b1100011;
  localparam logic [6:0] OP_JAL    = 7'b1101111;
  localparam logic [6:0] OP_JALR   = 7'b1100111;
  localparam logic [6:0] OP_LUI    = 7'b0110111;
  localparam logic [6:0] OP_AUIPC  = 7'b0010111;

  // ---- latched operands / results --------------------------------------
  logic [31:0] A, B, IMM, alu_result, mem_rdata_lat, link_pc;
  logic        branch_taken;

  // ---- ALU ---------------------------------------------------------------
  function automatic logic [31:0] alu_op(
    input logic [6:0] opc, input logic [2:0] f3, input logic [6:0] f7,
    input logic [31:0] a, input logic [31:0] b, input logic [31:0] imm
  );
    logic [31:0] operand_b;
    logic [4:0]  shamt;
    begin
      operand_b = (opc == OP_RTYPE) ? b : imm;
      shamt     = operand_b[4:0];
      case (f3)
        3'b000: alu_op = (opc == OP_RTYPE && f7[5]) ? (a - operand_b) : (a + operand_b); // SUB / ADD,ADDI
        3'b001: alu_op = a << shamt;                                                     // SLL/SLLI
        3'b010: alu_op = ($signed(a) < $signed(operand_b)) ? 32'h1 : 32'h0;              // SLT/SLTI
        3'b011: alu_op = (a < operand_b) ? 32'h1 : 32'h0;                                // SLTU/SLTIU
        3'b100: alu_op = a ^ operand_b;                                                  // XOR/XORI
        3'b101: alu_op = f7[5] ? ($signed(a) >>> shamt) : (a >> shamt);                  // SRA/SRAI vs SRL/SRLI
        3'b110: alu_op = a | operand_b;                                                  // OR/ORI
        3'b111: alu_op = a & operand_b;                                                  // AND/ANDI
        default: alu_op = 32'h0;
      endcase
    end
  endfunction

  function automatic logic branch_cond(
    input logic [2:0] f3, input logic [31:0] a, input logic [31:0] b
  );
    begin
      case (f3)
        3'b000: branch_cond = (a == b);                       // BEQ
        3'b001: branch_cond = (a != b);                       // BNE
        3'b100: branch_cond = ($signed(a) <  $signed(b));     // BLT
        3'b101: branch_cond = ($signed(a) >= $signed(b));     // BGE
        3'b110: branch_cond = (a < b);                        // BLTU
        3'b111: branch_cond = (a >= b);                       // BGEU
        default: branch_cond = 1'b0;
      endcase
    end
  endfunction

  // ---- FSM ----------------------------------------------------------------
  typedef enum logic [2:0] {S_FETCH, S_DECODE, S_EXEC, S_MEM, S_WB} state_t;
  state_t state, state_n;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= S_FETCH;
    else        state <= state_n;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc <= 32'h0;
    else if (state == S_WB) pc <= pc_n;
  end

  // fetch: register IR from instr_mem
  assign imem_addr = pc[IMEM_ADDR_BITS-1:0];
  always_ff @(posedge clk) begin
    if (state == S_FETCH) ir <= imem_rdata;
  end

  // decode: latch operands
  always_ff @(posedge clk) begin
    if (state == S_DECODE) begin
      A <= rs1_data;
      B <= rs2_data;
      case (opcode)
        OP_ITYPE, OP_LOAD, OP_JALR: IMM <= imm_i;
        OP_STORE:                   IMM <= imm_s;
        OP_BRANCH:                  IMM <= imm_b;
        OP_LUI, OP_AUIPC:           IMM <= imm_u;
        OP_JAL:                     IMM <= imm_j;
        default:                    IMM <= imm_i;
      endcase
    end
  end

  // execute: latch ALU result / branch decision / link address
  always_ff @(posedge clk) begin
    if (state == S_EXEC) begin
      case (opcode)
        OP_RTYPE, OP_ITYPE: alu_result <= alu_op(opcode, funct3, funct7, A, B, IMM);
        OP_LOAD, OP_STORE:  alu_result <= A + IMM; // virtual address for MMU
        OP_BRANCH:          branch_taken <= branch_cond(funct3, A, B);
        OP_LUI:              alu_result <= IMM;
        OP_AUIPC:            alu_result <= pc + IMM;
        OP_JAL, OP_JALR:     alu_result <= (opcode == OP_JALR) ? ((A + IMM) & ~32'h1) : (pc + IMM);
        default:              alu_result <= 32'h0;
      endcase
      link_pc <= pc + 32'd4;
    end
  end

  // memory stage: drive MMU, wait for ready, latch read data
  assign dmem_va    = alu_result[VA_WIDTH-1:0];
  assign dmem_wdata = B;
  assign dmem_re    = (state == S_MEM) && (opcode == OP_LOAD);
  assign dmem_we    = (state == S_MEM) && (opcode == OP_STORE);

  always_ff @(posedge clk) begin
    if (state == S_MEM && dmem_ready && opcode == OP_LOAD) mem_rdata_lat <= dmem_rdata;
  end

  // writeback: register file write + next PC
  always_comb begin
    reg_we    = 1'b0;
    reg_wdata = 32'h0;
    pc_n      = pc + 32'd4;

    if (state == S_WB) begin
      case (opcode)
        OP_RTYPE, OP_ITYPE, OP_LUI, OP_AUIPC: begin
          reg_we = 1'b1; reg_wdata = alu_result;
        end
        OP_LOAD: begin
          reg_we = 1'b1; reg_wdata = mem_rdata_lat;
        end
        OP_STORE: begin
          // no register write
        end
        OP_BRANCH: begin
          pc_n = branch_taken ? alu_result : (pc + 32'd4);
        end
        OP_JAL, OP_JALR: begin
          reg_we = 1'b1; reg_wdata = link_pc;
          pc_n   = alu_result;
        end
        default: ;
      endcase
    end
  end

  // ---- next-state logic ---------------------------------------------------
  always_comb begin
    state_n = state;
    case (state)
      S_FETCH:  state_n = S_DECODE;
      S_DECODE: state_n = S_EXEC;
      S_EXEC: begin
        if (opcode == OP_LOAD || opcode == OP_STORE) state_n = S_MEM;
        else                                          state_n = S_WB;
      end
      S_MEM: begin
        if (dmem_ready) state_n = S_WB; // wait for MMU (1 cycle hit, 2 on miss)
        else             state_n = S_MEM;
      end
      S_WB:     state_n = S_FETCH;
      default:  state_n = S_FETCH;
    endcase
  end

endmodule
