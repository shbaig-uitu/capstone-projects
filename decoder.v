`include "rv32i_soc_defines.v"

module decoder (
    input  wire [31:0] instr,
    output wire [4:0]  rs1_addr,
    output wire [4:0]  rs2_addr,
    output wire [4:0]  rd_addr,
    output wire [2:0]  funct3,
    output wire [31:0] imm,
    output reg  [3:0]  alu_op,
    output reg         reg_write,
    output reg         mem_read,
    output reg         mem_write,
    output reg         mem_to_reg,
    output reg         alu_src,
    output reg         branch,
    output reg         jump,
    output reg         jalr,
    output reg         lui,
    output reg         auipc
);

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    wire [6:0] opcode = instr[6:0];
    wire [6:0] funct7 = instr[31:25];

    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign rd_addr  = instr[11:7];
    assign funct3   = instr[14:12];

    reg [31:0] imm_i;
    reg [31:0] imm_s;
    reg [31:0] imm_b;
    reg [31:0] imm_u;
    reg [31:0] imm_j;
    reg [31:0] imm_sel;

    always @(*) begin
        imm_i = {{20{instr[31]}}, instr[31:20]};
        imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        imm_u = {instr[31:12], 12'b0};
        imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

        case (opcode)
            `OPCODE_ITYPE:  imm_sel = imm_i;
            `OPCODE_LOAD:   imm_sel = imm_i;
            `OPCODE_JALR:   imm_sel = imm_i;
            `OPCODE_STORE:  imm_sel = imm_s;
            `OPCODE_BRANCH: imm_sel = imm_b;
            `OPCODE_LUI:    imm_sel = imm_u;
            `OPCODE_AUIPC:  imm_sel = imm_u;
            `OPCODE_JAL:    imm_sel = imm_j;
            default:        imm_sel = 32'h0000_0000;
        endcase
    end

    assign imm = imm_sel;

    always @(*) begin
        alu_op     = ALU_ADD;
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        jalr       = 1'b0;
        lui        = 1'b0;
        auipc      = 1'b0;

        case (opcode)
            `OPCODE_RTYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                case (funct3)
                    3'b000: alu_op = (funct7[5]) ? ALU_SUB : ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: alu_op = ALU_ADD;
                endcase
            end

            `OPCODE_ITYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                case (funct3)
                    3'b000: alu_op = ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: alu_op = ALU_ADD;
                endcase
            end

            `OPCODE_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_op     = ALU_ADD;
            end

            `OPCODE_STORE: begin
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_op    = ALU_ADD;
            end

            `OPCODE_BRANCH: begin
                alu_src = 1'b0;
                branch  = 1'b1;
                case (funct3)
                    3'b000: alu_op = ALU_SUB;
                    3'b001: alu_op = ALU_SUB;
                    3'b100: alu_op = ALU_SLT;
                    3'b101: alu_op = ALU_SLT;
                    3'b110: alu_op = ALU_SLTU;
                    3'b111: alu_op = ALU_SLTU;
                    default: alu_op = ALU_SUB;
                endcase
            end

            `OPCODE_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
            end

            `OPCODE_JALR: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                jalr      = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_ADD;
            end

            `OPCODE_LUI: begin
                reg_write = 1'b1;
                lui       = 1'b1;
            end

            `OPCODE_AUIPC: begin
                reg_write = 1'b1;
                auipc     = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_ADD;
            end

            default: begin
                reg_write = 1'b0;
            end
        endcase
    end

endmodule
