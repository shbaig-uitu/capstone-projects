module control_unit (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg        alu_src,       // 0: rs2_data, 1: imm
    output reg        mem_read,      // Data memory / AXI read
    output reg        mem_write,     // Data memory / AXI write
    output reg  [1:0] mem_to_reg,    // 00: ALU result, 01: Mem Data, 10: PC+4 (for JAL/JALR), 11: Imm (LUI)
    output reg        branch,        // 1 for B-type
    output reg        jump,          // 1 for JAL / JALR
    output reg        jump_reg,      // 1 for JALR (Base is rs1, not PC)
    output reg  [1:0] alu_op         // 00: Add (Load/Store), 01: Branch, 10: R/I-type ALU, 11: Pass-through
);

    always @(*) begin
        // Default values (Safe state)
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 2'b00;
        branch     = 1'b0;
        jump       = 1'b0;
        jump_reg   = 1'b0;
        alu_op     = 2'b00;

        case (opcode)
            // R-Type: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
            7'b0110011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b0;     // Operand B = rs2_data
                mem_to_reg = 2'b00;    // Write ALU result to reg
                alu_op     = 2'b10;    // Look at funct3 & funct7
            end

            // I-Type ALU: ADDI, SLTI, ANDI, ORI, XORI, SLLI, SRLI, SRAI
            7'b0010011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;     // Operand B = imm
                mem_to_reg = 2'b00;    // Write ALU result to reg
                alu_op     = 2'b10;    // Look at funct3
            end

            // I-Type Load: LW
            7'b0000011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;     // Addr = rs1 + imm
                mem_read   = 1'b1;     // Read from memory / AXI
                mem_to_reg = 2'b01;    // Write Mem Data to reg
                alu_op     = 2'b00;    // Force ADD
            end

            // S-Type Store: SW
            7'b0100011: begin
                alu_src    = 1'b1;     // Addr = rs1 + imm
                mem_write  = 1'b1;     // Write to memory / AXI
                alu_op     = 2'b00;    // Force ADD
            end

            // B-Type Branch: BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011: begin
                alu_src    = 1'b0;     // Compare rs1 and rs2
                branch     = 1'b1;
                alu_op     = 2'b01;    // Branch compare
            end

            // J-Type: JAL (Jump and Link)
            7'b1101111: begin
                reg_write  = 1'b1;
                mem_to_reg = 2'b10;    // rd = PC + 4
                jump       = 1'b1;
            end

            // I-Type: JALR (Jump and Link Register)
            7'b1100111: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;     // Target = rs1 + imm
                mem_to_reg = 2'b10;    // rd = PC + 4
                jump       = 1'b1;
                jump_reg   = 1'b1;
                alu_op     = 2'b00;    // Force ADD for target
            end

            // U-Type: LUI (Load Upper Immediate)
            7'b0110111: begin
                reg_write  = 1'b1;
                mem_to_reg = 2'b11;    // rd = imm
            end

            default: ; // Defaults already set
        endcase
    end

endmodule