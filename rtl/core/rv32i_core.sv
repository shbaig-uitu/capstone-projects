/**
 * RISC-V SoC with Virtual Memory Support
 * Capstone Project
 * 
 * File: rv32i_core.sv
 * Description: Complete RV32I single-cycle processor core
 *              Full instruction decode, ALU, and register file
 *              Supports virtual memory through MMU interface
 */

`include "../include/riscv_defines.sv"
`include "../include/riscv_types.sv"

module rv32i_core (
  input  logic                clk,
  input  logic                rst_n,
  
  // Instruction Memory Interface (Virtual Addresses)
  output logic [`ADDR_WIDTH-1:0]  inst_vaddr,
  output logic                    inst_valid,
  input  logic [`ILEN-1:0]        inst_data,
  input  logic                    inst_ready,
  input  logic                    inst_page_fault,
  
  // Data Memory Interface (Virtual Addresses)
  output logic [`ADDR_WIDTH-1:0]  data_vaddr,
  output logic                    data_valid,
  output logic                    data_write,
  output logic [`DATA_WIDTH-1:0]  data_wdata,
  output logic [3:0]              data_byte_en,
  input  logic [`DATA_WIDTH-1:0]  data_rdata,
  input  logic                    data_ready,
  input  logic                    data_page_fault,
  
  // CSR Interface
  output logic                    csr_valid,
  output logic [11:0]             csr_addr,
  output logic [`DATA_WIDTH-1:0]  csr_wdata,
  output logic [1:0]              csr_op,
  input  logic [`DATA_WIDTH-1:0]  csr_rdata,
  input  logic                    csr_ready,
  
  // Interrupt & Exception Signals
  output logic                    exception_valid,
  output logic [3:0]              exception_code,
  output logic [`ADDR_WIDTH-1:0]  exception_badaddr,
  
  // Debug Interface
  input  logic [4:0]              debug_reg_addr,
  output logic [`DATA_WIDTH-1:0]  debug_reg_data,
  output logic [`ADDR_WIDTH-1:0]  debug_pc
);

  // ============================================================================
  // Register File - 32 general purpose registers
  // ============================================================================
  
  logic [`DATA_WIDTH-1:0] regfile [0:`NUM_REGISTERS-1];
  logic [`DATA_WIDTH-1:0] rs1_data, rs2_data;
  
  // ============================================================================
  // Program Counter and Next PC Logic
  // ============================================================================
  
  logic [`ADDR_WIDTH-1:0] pc, pc_next;
  logic [`ADDR_WIDTH-1:0] pc_plus4;
  
  // ============================================================================
  // Instruction Decode Signals
  // ============================================================================
  
  logic [`ILEN-1:0]       instr;
  logic [6:0]             opcode;
  logic [4:0]             rd, rs1, rs2;
  logic [2:0]             funct3;
  logic [6:0]             funct7;
  logic [11:0]            imm_i;
  logic [11:0]            imm_s;
  logic [12:0]            imm_b;
  logic [19:0]            imm_u;
  logic [20:0]            imm_j;
  
  // Sign-extended immediates
  logic [`DATA_WIDTH-1:0] imm_i_ext, imm_s_ext, imm_b_ext, imm_u_ext, imm_j_ext;
  
  // ============================================================================
  // ALU Signals
  // ============================================================================
  
  logic [`DATA_WIDTH-1:0] alu_in1, alu_in2, alu_out;
  logic [3:0]             alu_op;
  logic                   alu_zero;
  logic                   branch_taken;
  
  // ============================================================================
  // Control Signals
  // ============================================================================
  
  logic                   mem_write, mem_read;
  logic [1:0]             mem_size;      // 00=byte, 01=half, 10=word
  logic                   reg_write;
  logic [1:0]             alu_src1, alu_src2;  // Mux controls
  logic                   mem_access;
  
  // ============================================================================
  // State Machine
  // ============================================================================
  
  enum logic [2:0] {
    FETCH = 3'b000,
    EXECUTE = 3'b001,
    MEMORY = 3'b010,
    WRITEBACK = 3'b011
  } state, state_next;

  // ============================================================================
  // Pipeline Registers
  // ============================================================================
  
  logic [`ILEN-1:0]        instr_exec;
  logic [`DATA_WIDTH-1:0]  rd_data_exec;
  logic                    reg_write_exec;
  logic [4:0]              rd_exec;
  logic [`DATA_WIDTH-1:0]  mem_rdata;

  // ============================================================================
  // Debug Interface
  // ============================================================================
  
  assign debug_pc = pc;
  assign debug_reg_data = (debug_reg_addr == 0) ? '0 : regfile[debug_reg_addr];

  // ============================================================================
  // Register File Read
  // ============================================================================
  
  assign rs1_data = (rs1 == 0) ? '0 : regfile[rs1];
  assign rs2_data = (rs2 == 0) ? '0 : regfile[rs2];

  // ============================================================================
  // Program Counter Management
  // ============================================================================
  
  assign pc_plus4 = pc + 4;
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc <= '0;
      state <= FETCH;
      instr_exec <= 32'h00000013;  // NOP (addi x0, x0, 0)
      rd_data_exec <= '0;
      reg_write_exec <= 1'b0;
      rd_exec <= '0;
      mem_rdata <= '0;
    end else begin
      pc <= pc_next;
      state <= state_next;
      
      // Pipeline storage
      if (state == FETCH && inst_ready) begin
        instr_exec <= inst_data;
      end
      
      if (state == MEMORY && data_ready) begin
        mem_rdata <= data_rdata;
      end
      
      if (state == WRITEBACK) begin
        rd_data_exec <= alu_out;
        reg_write_exec <= reg_write;
        rd_exec <= rd;
      end
    end
  end

  // ============================================================================
  // Instruction Decode
  // ============================================================================
  
  assign instr = inst_data;
  assign opcode = instr[6:0];
  assign rd = instr[11:7];
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];
  
  // Extract immediates
  assign imm_i = instr[31:20];
  assign imm_s = {instr[31:25], instr[11:7]};
  assign imm_b = {instr[31], instr[7], instr[30:25], instr[11:8]};
  assign imm_u = instr[31:12];
  assign imm_j = {instr[31], instr[19:12], instr[20], instr[30:21]};
  
  // Sign-extend immediates
  assign imm_i_ext = {{20{imm_i[11]}}, imm_i};
  assign imm_s_ext = {{20{imm_s[11]}}, imm_s};
  assign imm_b_ext = {{19{imm_b[12]}}, imm_b, 1'b0};
  assign imm_u_ext = {imm_u, 12'b0};
  assign imm_j_ext = {{11{imm_j[20]}}, imm_j, 1'b0};

  // ============================================================================
  // Instruction Decode & Control Logic (EXECUTE State)
  // ============================================================================
  
  always_comb begin
    // Default values
    reg_write = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    mem_size = 2'b10;      // word by default
    alu_op = 4'd0;         // ADD
    alu_src1 = 2'b00;      // rs1
    alu_src2 = 2'b00;      // rs2
    pc_next = pc_plus4;    // default: sequential
    state_next = FETCH;
    mem_access = 1'b0;
    branch_taken = 1'b0;
    
    // CSR signals
    csr_valid = 1'b0;
    csr_addr = '0;
    csr_wdata = '0;
    csr_op = 2'b00;
    
    exception_valid = 1'b0;
    exception_code = `EXC_NONE;
    exception_badaddr = pc;
    
    // ========== STATE MACHINE ==========
    case (state)
      FETCH: begin
        inst_vaddr = pc;
        inst_valid = 1'b1;
        
        if (inst_ready && !inst_page_fault) begin
          state_next = EXECUTE;
        end else if (inst_page_fault) begin
          exception_valid = 1'b1;
          exception_code = `EXC_INSTR_PAGE_FAULT;
          exception_badaddr = pc;
          state_next = FETCH;
        end else begin
          state_next = FETCH;
        end
      end
      
      EXECUTE: begin
        inst_vaddr = pc;
        inst_valid = 1'b0;
        
        // ========== INSTRUCTION DECODE ==========
        case (opcode)
          // ==== LOAD Instructions (LW, LH, LB, LHU, LBU) ====
          `OP_LOAD: begin
            alu_src1 = 2'b00;           // rs1
            alu_src2 = 2'b01;           // imm_i
            alu_op = 4'b0000;           // ADD (address calculation)
            mem_read = 1'b1;
            state_next = MEMORY;
            
            case (funct3)
              `FUNCT3_LB:  mem_size = 2'b00;  // Load byte
              `FUNCT3_LH:  mem_size = 2'b01;  // Load half-word
              `FUNCT3_LW:  mem_size = 2'b10;  // Load word
              `FUNCT3_LBU: mem_size = 2'b00;  // Load byte unsigned
              `FUNCT3_LHU: mem_size = 2'b01;  // Load half unsigned
              default: mem_size = 2'b10;
            endcase
          end
          
          // ==== STORE Instructions (SW, SH, SB) ====
          `OP_STORE: begin
            alu_src1 = 2'b00;           // rs1
            alu_src2 = 2'b01;           // imm_s
            alu_op = 4'b0000;           // ADD (address calculation)
            mem_write = 1'b1;
            state_next = MEMORY;
            
            case (funct3)
              `FUNCT3_SB: mem_size = 2'b00;
              `FUNCT3_SH: mem_size = 2'b01;
              `FUNCT3_SW: mem_size = 2'b10;
              default: mem_size = 2'b10;
            endcase
          end
          
          // ==== IMMEDIATE Arithmetic (ADDI, ANDI, ORI, XORI, SLTI, SLLI, SRLI, SRAI) ====
          `OP_IMM: begin
            alu_src1 = 2'b00;           // rs1
            alu_src2 = 2'b01;           // imm_i
            reg_write = 1'b1;
            
            case (funct3)
              3'b000: alu_op = 4'b0000; // ADDI
              3'b010: alu_op = 4'b0011; // SLTI
              3'b011: alu_op = 4'b1011; // SLTIU
              3'b100: alu_op = 4'b0111; // XORI
              3'b110: alu_op = 4'b0110; // ORI
              3'b111: alu_op = 4'b0100; // ANDI
              3'b001: alu_op = 4'b0001; // SLLI
              3'b101: begin              // SRLI / SRAI
                if (funct7[5]) alu_op = 4'b1101; // SRAI
                else alu_op = 4'b0101;           // SRLI
              end
              default: alu_op = 4'b0000;
            endcase
            
            state_next = WRITEBACK;
          end
          
          // ==== REGISTER Arithmetic (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU) ====
          `OP_REG: begin
            alu_src1 = 2'b00;           // rs1
            alu_src2 = 2'b00;           // rs2
            reg_write = 1'b1;
            
            case (funct3)
              3'b000: alu_op = funct7[5] ? 4'b1000 : 4'b0000;  // ADD/SUB
              3'b001: alu_op = 4'b0001; // SLL
              3'b010: alu_op = 4'b0011; // SLT
              3'b011: alu_op = 4'b1011; // SLTU
              3'b100: alu_op = 4'b0111; // XOR
              3'b101: alu_op = funct7[5] ? 4'b1101 : 4'b0101;  // SRL/SRA
              3'b110: alu_op = 4'b0110; // OR
              3'b111: alu_op = 4'b0100; // AND
              default: alu_op = 4'b0000;
            endcase
            
            state_next = WRITEBACK;
          end
          
          // ==== LUI (Load Upper Immediate) ====
          `OP_LUI: begin
            alu_src1 = 2'b10;           // imm_u (pre-shifted)
            alu_src2 = 2'b00;           // rs2 (unused)
            alu_op = 4'b0000;           // ADD (acts as pass-through)
            reg_write = 1'b1;
            state_next = WRITEBACK;
          end
          
          // ==== AUIPC (Add Upper Immediate to PC) ====
          `OP_AUIPC: begin
            alu_src1 = 2'b11;           // pc
            alu_src2 = 2'b10;           // imm_u
            alu_op = 4'b0000;           // ADD
            reg_write = 1'b1;
            state_next = WRITEBACK;
          end
          
          // ==== JAL (Jump and Link) ====
          `OP_JAL: begin
            alu_src1 = 2'b11;           // pc
            alu_src2 = 2'b11;           // immediate 4
            alu_op = 4'b0000;           // ADD (pc + 4)
            reg_write = 1'b1;           // Save return address
            pc_next = pc + imm_j_ext;   // Jump to target
            state_next = WRITEBACK;
          end
          
          // ==== JALR (Jump and Link Register) ====
          `OP_JALR: begin
            alu_src1 = 2'b11;           // pc
            alu_src2 = 2'b11;           // immediate 4
            alu_op = 4'b0000;           // ADD (pc + 4)
            reg_write = 1'b1;           // Save return address
            pc_next = (rs1_data + imm_i_ext) & 32'hFFFFFFFE;
            state_next = WRITEBACK;
          end
          
          // ==== BRANCH Instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU) ====
          `OP_BRANCH: begin
            alu_src1 = 2'b00;           // rs1
            alu_src2 = 2'b00;           // rs2
            
            case (funct3)
              3'b000: branch_taken = (rs1_data == rs2_data);           // BEQ
              3'b001: branch_taken = (rs1_data != rs2_data);           // BNE
              3'b100: branch_taken = ($signed(rs1_data) < $signed(rs2_data)); // BLT
              3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data)); // BGE
              3'b110: branch_taken = (rs1_data < rs2_data);            // BLTU
              3'b111: branch_taken = (rs1_data >= rs2_data);           // BGEU
              default: branch_taken = 1'b0;
            endcase
            
            if (branch_taken)
              pc_next = pc + imm_b_ext;
            
            state_next = WRITEBACK;
          end
          
          // ==== FENCE (No-op in this implementation) ====
          `OP_FENCE: begin
            state_next = WRITEBACK;
          end
          
          // ==== System Instructions (ECALL, EBREAK, CSRRW, CSRRS, CSRRC) ====
          `OP_SYSTEM: begin
            // Check if it's a CSR instruction (funct3 != 0)
            if (funct3 != 3'b000) begin
              // CSR instructions
              csr_valid = 1'b1;
              csr_addr = imm_i;
              csr_wdata = rs1_data;
              csr_op = {1'b0, funct3[1]};  // 01=write, 10=set, 11=clear
              state_next = WRITEBACK;
            end else if (instr[31:20] == 12'b0) begin           // ECALL
              exception_valid = 1'b1;
              exception_code = `EXC_ECALL_M;
              exception_badaddr = pc;
            end else if (instr[31:20] == 12'b1) begin  // EBREAK
              exception_valid = 1'b1;
              exception_code = `EXC_BREAKPOINT;
              exception_badaddr = pc;
            end
            state_next = FETCH;
          end
          
          // ==== Default (Invalid Instruction) ====
          default: begin
            state_next = FETCH;
          end
        endcase
      end
      
      MEMORY: begin
        inst_vaddr = pc;
        inst_valid = 1'b0;
        
        // Calculate effective address
        alu_src1 = 2'b00;               // rs1
        alu_src2 = mem_write ? 2'b10 : 2'b01;  // imm_s or imm_i
        alu_op = 4'b0000;               // ADD
        
        data_vaddr = alu_out;
        data_valid = 1'b1;
        data_write = mem_write;
        data_wdata = rs2_data;
        
        // Byte enable based on mem_size and address[1:0]
        case (mem_size)
          2'b00: data_byte_en = 4'b0001 << alu_out[1:0];  // Byte
          2'b01: data_byte_en = 4'b0011 << alu_out[1:0];  // Half-word
          2'b10: data_byte_en = 4'b1111;                   // Word
          default: data_byte_en = 4'b1111;
        endcase
        
        if (data_ready && !data_page_fault) begin
          state_next = WRITEBACK;
          if (mem_read) reg_write = 1'b1;
        end else if (data_page_fault) begin
          exception_valid = 1'b1;
          exception_code = mem_read ? `EXC_LOAD_PAGE_FAULT : `EXC_STORE_PAGE_FAULT;
          exception_badaddr = data_vaddr;
          state_next = FETCH;
        end
      end
      
      WRITEBACK: begin
        inst_vaddr = pc;
        inst_valid = 1'b0;
        
        // Handle CSR write result
        if (csr_valid) begin
          // CSR read-modify-write: write result to destination register
          if (rd != 0) begin
            regfile[rd] <= csr_rdata;
          end
        end
        
        state_next = FETCH;
      end
      
      default: begin
        state_next = FETCH;
      end
    endcase
  end

  // ============================================================================
  // ALU Implementation
  // ============================================================================
  
  always_comb begin
    // ALU operand selection
    case (alu_src1)
      2'b00: alu_in1 = rs1_data;
      2'b01: alu_in1 = pc;
      2'b10: alu_in1 = '0;
      2'b11: alu_in1 = '0;
      default: alu_in1 = rs1_data;
    endcase
    
    case (alu_src2)
      2'b00: alu_in2 = rs2_data;
      2'b01: alu_in2 = imm_i_ext;
      2'b10: alu_in2 = imm_u_ext;
      2'b11: alu_in2 = 32'd4;  // For PC+4 and JAL offset
      default: alu_in2 = rs2_data;
    endcase
    
    // ALU operations
    case (alu_op)
      4'b0000: alu_out = alu_in1 + alu_in2;              // ADD
      4'b1000: alu_out = alu_in1 - alu_in2;              // SUB
      4'b0001: alu_out = alu_in1 << alu_in2[4:0];        // SLL (Shift Left Logical)
      4'b0101: alu_out = alu_in1 >> alu_in2[4:0];        // SRL (Shift Right Logical)
      4'b1101: alu_out = $signed(alu_in1) >>> alu_in2[4:0]; // SRA (Shift Right Arithmetic)
      4'b0111: alu_out = alu_in1 ^ alu_in2;              // XOR
      4'b0110: alu_out = alu_in1 | alu_in2;              // OR
      4'b0100: alu_out = alu_in1 & alu_in2;              // AND
      4'b0011: alu_out = {31'b0, $signed(alu_in1) < $signed(alu_in2)}; // SLT (Set Less Than)
      4'b1011: alu_out = {31'b0, alu_in1 < alu_in2};     // SLTU (Set Less Than Unsigned)
      default: alu_out = alu_in1 + alu_in2;
    endcase
  end

  // ============================================================================
  // Register File Write Back
  // ============================================================================
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < `NUM_REGISTERS; i = i + 1)
        regfile[i] <= '0;
    end else if (reg_write && rd != 0) begin
      regfile[rd] <= alu_out;
    end else if (mem_read && data_ready && rd != 0) begin
      // Sign/zero-extend based on load instruction type
      case (mem_size)
        2'b00: begin  // Byte
          if (instr_exec[14:12] == `FUNCT3_LBU)
            regfile[rd] <= {24'b0, mem_rdata[7:0]};
          else
            regfile[rd] <= {{24{mem_rdata[7]}}, mem_rdata[7:0]};
        end
        2'b01: begin  // Half-word
          if (instr_exec[14:12] == `FUNCT3_LHU)
            regfile[rd] <= {16'b0, mem_rdata[15:0]};
          else
            regfile[rd] <= {{16{mem_rdata[15]}}, mem_rdata[15:0]};
        end
        2'b10: regfile[rd] <= mem_rdata;  // Word
        default: regfile[rd] <= mem_rdata;
      endcase
    end
  end

endmodule
