// riscv_core.v Complete single-cycle RV32I CPU
// Supports: R-type, I-type ALU, LW/LH/LB/LHU/LBU, SW/SH/SB,
//           BEQ/BNE/BLT/BGE/BLTU/BGEU, JAL, JALR, LUI, AUIPC
module riscv_core (
    input clk,
    input rst,
    input         stall,
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    output        mem_we,
    output        mem_read,
    output [ 2:0] mem_funct3,
    input  [31:0] mem_rdata,
    output [31:0] cpu_x7,
    output [31:0] cpu_x8
);
    //1. Program Counter
    reg  [31:0] pc;
    wire [31:0] pc4 = pc + 4;

    //2. Instruction Fetch
    wire [31:0] inst;
    imem imem0 (.addr(pc), .instr(inst)); // Fixed port name

    //3. Instruction Decode
    wire [6:0] opcode = inst[6:0];
    wire [4:0] rd     = inst[11:7];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1    = inst[19:15];
    wire [4:0] rs2    = inst[24:20];
    wire [6:0] funct7 = inst[31:25];

    // 4. Control Unit
    wire reg_write, alu_src, mem_write, branch, jump;
    wire [1:0] wb_sel;
    wire [3:0] alu_op;
    wire [2:0] imm_sel;

    control ctrl (
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .reg_write(reg_write), .alu_src(alu_src),
        .mem_read(mem_read), .mem_write(mem_write), 
        .wb_sel(wb_sel), .alu_op(alu_op), 
        .branch(branch), .jump(jump), .imm_sel(imm_sel) // Fixed port names
    );

    //5. Register File
    wire [31:0] rdata1, rdata2, wr_data;
    regfile rf (
        .clk(clk), 
        .we(reg_write & ~stall), // <-- FIXED: Only write when not stalled
        .raddr1(rs1), .raddr2(rs2), .waddr(rd),
        .wdata(wr_data), .rdata1(rdata1), .rdata2(rdata2),
        .x7_out(cpu_x7),
        .x8_out(cpu_x8)
    );

    //6. Immediate Generator
    wire [31:0] imm;
    immgen ig (.instr(inst), .imm_sel(imm_sel), .imm(imm)); // Fixed port names

    //7. ALU
    wire [31:0] alu_b = alu_src ? imm : rdata2;
    wire [31:0] alu_out;
    wire        alu_zero;
    alu alu0 (
        .a(rdata1), .b(alu_b), .alu_op(alu_op), // Fixed port names
        .result(alu_out), .zero(alu_zero)       // Removed lt/ltu (not in alu.v)
    );

    //8. Data Memory
    assign mem_addr   = alu_out;
    assign mem_wdata  = rdata2;
    assign mem_we     = mem_write;
    assign mem_funct3 = funct3;

    //9. Branch Unit
    // Compute lt and ltu manually since they aren't in alu.v
    wire alu_lt  = ($signed(rdata1) < $signed(rdata2));
    wire alu_ltu = (rdata1 < rdata2);
    
    wire        branch_taken;
    wire [31:0] branch_target;
    branch_unit bu (
        .funct3(funct3), .zero(alu_zero),
        .alu_lt(alu_lt), .alu_ltu(alu_ltu),
        .pc(pc), .b_imm(imm),
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );

    //10. PC Mux
    wire [31:0] jal_target  = pc + imm;
    wire [31:0] jalr_target = (rdata1 + imm) & ~32'h1;
    
    wire is_jal  = (opcode == 7'b1101111);
    wire is_jalr = (opcode == 7'b1100111);

    wire [31:0] pc_next =
        (branch & branch_taken) ? branch_target :
        (jump & is_jal)         ? jal_target    :
        (jump & is_jalr)        ? jalr_target   : pc4;

    always @(posedge clk)
        if (rst) 
            pc <= 0; 
        else if (!stall)  // <-- NEW: Freeze PC if stalled
            pc <= pc_next;

    //11. Write-Back Mux
    // wb_sel: 00=ALU, 01=MEM, 10=PC+4, 11=Uimm
    assign wr_data = (wb_sel == 2'b00) ? alu_out :
                     (wb_sel == 2'b01) ? mem_rdata :
                     (wb_sel == 2'b10) ? pc4 :
                     (wb_sel == 2'b11) ? imm : 32'd0;

endmodule
