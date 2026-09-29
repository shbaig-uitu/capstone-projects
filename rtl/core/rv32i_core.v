// Custom synthesizable RV32I multicycle CPU for Project 02.
// Implements the base RV32I integer instruction set (no M/C/F extensions).
// Native single-request memory interface is used by the SoC interconnect.
module rv32i_core #(
    parameter RESET_PC = 32'h0000_0000
)(
    input  wire        clk,
    input  wire        resetn,
    output reg         trap,
    output reg         mem_valid,
    output reg         mem_instr,
    input  wire        mem_ready,
    output reg [31:0]  mem_addr,
    output reg [31:0]  mem_wdata,
    output reg [3:0]   mem_wstrb,
    input  wire [31:0] mem_rdata,
    output wire [31:0] dbg_pc
);
    localparam S_FETCH = 2'd0;
    localparam S_EXEC  = 2'd1;
    localparam S_MEM   = 2'd2;
    // One idle cycle after a data transaction lets the interconnect observe
    // mem_valid going low before the next request.
    localparam S_GAP   = 2'd3;

    reg [1:0] state;
    reg [31:0] pc;
    reg [31:0] instr;
    reg [31:0] regs [0:31];

    reg [31:0] mem_addr_r, mem_wdata_r;
    reg [3:0]  mem_wstrb_r;
    reg        mem_is_load;
    reg [2:0]  mem_funct3;
    reg [4:0]  mem_rd;
    reg [31:0] mem_load_addr;

    integer i;

    assign dbg_pc = pc;

    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    wire [4:0] rd = instr[11:7];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [31:0] rs1_val = (rs1 == 0) ? 32'h0 : regs[rs1];
    wire [31:0] rs2_val = (rs2 == 0) ? 32'h0 : regs[rs2];

    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_u = {instr[31:12], 12'b0};
    wire [31:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    wire [31:0] exec_mem_addr = rs1_val + imm_s;
    wire [31:0] load_addr = rs1_val + imm_i;
    wire [31:0] jalr_target = load_addr & 32'hffff_fffe;
    wire [31:0] branch_target = (pc - 4) + imm_b;
    wire [31:0] jal_target = (pc - 4) + imm_j;
    wire branch_eq  = (rs1_val == rs2_val);
    wire branch_ne  = (rs1_val != rs2_val);
    wire branch_lt  = ($signed(rs1_val) < $signed(rs2_val));
    wire branch_ge  = ($signed(rs1_val) >= $signed(rs2_val));
    wire branch_ltu = (rs1_val < rs2_val);
    wire branch_geu = (rs1_val >= rs2_val);

    function [31:0] load_extend;
        input [31:0] word;
        input [1:0]  offs;
        input [2:0]  f3;
        reg [7:0] b;
        reg [15:0] h;
        begin
            b = (offs == 2'd0) ? word[7:0] :
                (offs == 2'd1) ? word[15:8] :
                (offs == 2'd2) ? word[23:16] : word[31:24];
            h = (offs[1] == 1'b0) ? word[15:0] : word[31:16];
            case (f3)
                3'b000: load_extend = {{24{b[7]}}, b};       // LB
                3'b001: load_extend = {{16{h[15]}}, h};      // LH
                3'b010: load_extend = word;                  // LW
                3'b100: load_extend = {24'h0, b};            // LBU
                3'b101: load_extend = {16'h0, h};            // LHU
                default: load_extend = 32'h0;
            endcase
        end
    endfunction

    task write_rd;
        input [4:0] d;
        input [31:0] v;
        begin
            if (d != 0) regs[d] <= v;
        end
    endtask

    always @(*) begin
        mem_valid = 1'b0;
        mem_instr = 1'b0;
        mem_addr = mem_addr_r;
        mem_wdata = mem_wdata_r;
        mem_wstrb = mem_wstrb_r;
        if (state == S_FETCH) begin
            mem_valid = 1'b1;
            mem_instr = 1'b1;
            mem_addr = pc;
            mem_wstrb = 4'h0;
        end else if (state == S_MEM) begin
            mem_valid = 1'b1;
            mem_instr = 1'b0;
            mem_addr = mem_addr_r;
            mem_wdata = mem_wdata_r;
            mem_wstrb = mem_wstrb_r;
        end
    end

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= S_FETCH;
            pc <= RESET_PC;
            instr <= 32'h00000013; // NOP
            trap <= 1'b0;
            mem_addr_r <= 0;
            mem_wdata_r <= 0;
            mem_wstrb_r <= 0;
            mem_is_load <= 0;
            mem_funct3 <= 0;
            mem_rd <= 0;
            mem_load_addr <= 0;
            for (i = 0; i < 32; i = i + 1) regs[i] <= 32'h0;
        end else begin
            regs[0] <= 32'h0;
            case (state)
                S_FETCH: begin
                    if (mem_ready) begin
                        instr <= mem_rdata;
                        pc <= pc + 32'd4;
                        state <= S_EXEC;
                    end
                end

                S_EXEC: begin
                    case (opcode)
                        7'b0110111: begin // LUI
                            write_rd(rd, imm_u);
                            state <= S_FETCH;
                        end
                        7'b0010111: begin // AUIPC
                            write_rd(rd, (pc - 4) + imm_u);
                            state <= S_FETCH;
                        end
                        7'b1101111: begin // JAL
                            if (jal_target[1:0] == 2'b00) begin
                                write_rd(rd, pc);
                                pc <= (pc - 4) + imm_j;
                            end else begin
                                trap <= 1'b1;
                            end
                            state <= S_FETCH;
                        end
                        7'b1100111: begin // JALR
                            if (funct3 == 3'b000 && jalr_target[1:0] == 2'b00) begin
                                write_rd(rd, pc);
                                pc <= jalr_target;
                                state <= S_FETCH;
                            end else begin
                                trap <= 1'b1;
                                state <= S_FETCH;
                            end
                        end
                        7'b1100011: begin // BRANCH
                            // instr[31:25] is part of the B-type immediate, not funct7.
                            case (funct3)
                                    3'b000: begin // BEQ
                                        if (branch_eq) begin
                                            if (branch_target[1:0] == 2'b00) pc <= branch_target;
                                            else trap <= 1'b1;
                                        end
                                    end
                                    3'b001: begin // BNE
                                        if (branch_ne) begin
                                            if (branch_target[1:0] == 2'b00) pc <= branch_target;
                                            else trap <= 1'b1;
                                        end
                                    end
                                    3'b100: begin // BLT
                                        if (branch_lt) begin
                                            if (branch_target[1:0] == 2'b00) pc <= branch_target;
                                            else trap <= 1'b1;
                                        end
                                    end
                                    3'b101: begin // BGE
                                        if (branch_ge) begin
                                            if (branch_target[1:0] == 2'b00) pc <= branch_target;
                                            else trap <= 1'b1;
                                        end
                                    end
                                    3'b110: begin // BLTU
                                        if (branch_ltu) begin
                                            if (branch_target[1:0] == 2'b00) pc <= branch_target;
                                            else trap <= 1'b1;
                                        end
                                    end
                                    3'b111: begin // BGEU
                                        if (branch_geu) begin
                                            if (branch_target[1:0] == 2'b00) pc <= branch_target;
                                            else trap <= 1'b1;
                                        end
                                    end
                                    default: trap <= 1'b1;
                                endcase
                            state <= S_FETCH;
                        end
                        7'b0000011: begin // LOAD
                            if ((funct3==3'b000 || funct3==3'b100) ||
                                ((funct3==3'b001 || funct3==3'b101) && !load_addr[0]) ||
                                (funct3==3'b010 && load_addr[1:0] == 2'b00)) begin
                                mem_addr_r <= rs1_val + imm_i;
                                mem_wdata_r <= 0;
                                mem_wstrb_r <= 0;
                                mem_is_load <= 1'b1;
                                mem_funct3 <= funct3;
                                mem_rd <= rd;
                                mem_load_addr <= rs1_val + imm_i;
                                state <= S_MEM;
                            end else begin
                                trap <= 1'b1;
                                state <= S_FETCH;
                            end
                        end
                        7'b0100011: begin // STORE
                            if (funct3==3'b000 ||
                                (funct3==3'b001 && exec_mem_addr[0] == 1'b0) ||
                                (funct3==3'b010 && exec_mem_addr[1:0] == 2'b00)) begin
                                mem_addr_r <= exec_mem_addr;
                                case (funct3)
                                    3'b000: begin // SB
                                        mem_wstrb_r <= 4'b0001 << exec_mem_addr[1:0];
                                        mem_wdata_r <= rs2_val << (8*exec_mem_addr[1:0]);
                                    end
                                    3'b001: begin // SH
                                        mem_wstrb_r <= exec_mem_addr[1] ? 4'b1100 : 4'b0011;
                                        mem_wdata_r <= exec_mem_addr[1] ? (rs2_val << 16) : rs2_val;
                                    end
                                    default: begin mem_wstrb_r <= 4'b1111; mem_wdata_r <= rs2_val; end // SW
                                endcase
                                mem_is_load <= 1'b0;
                                state <= S_MEM;
                            end else begin
                                trap <= 1'b1;
                                state <= S_FETCH;
                            end
                        end
                        7'b0010011: begin // OP-IMM
                            case (funct3)
                                3'b000: write_rd(rd, rs1_val + imm_i); // ADDI
                                3'b010: write_rd(rd, ($signed(rs1_val) < $signed(imm_i)) ? 1 : 0);
                                3'b011: write_rd(rd, (rs1_val < imm_i) ? 1 : 0);
                                3'b100: write_rd(rd, rs1_val ^ imm_i);
                                3'b110: write_rd(rd, rs1_val | imm_i);
                                3'b111: write_rd(rd, rs1_val & imm_i);
                                3'b001: begin
                                    if (funct7 == 7'b0000000) write_rd(rd, rs1_val << instr[24:20]);
                                    else trap <= 1'b1;
                                end
                                3'b101: begin
                                    if (funct7 == 7'b0000000) write_rd(rd, rs1_val >> instr[24:20]);
                                    else if (funct7 == 7'b0100000) write_rd(rd, $signed(rs1_val) >>> instr[24:20]);
                                    else trap <= 1'b1;
                                end
                                default: trap <= 1'b1;
                            endcase
                            state <= S_FETCH;
                        end
                        7'b0110011: begin // OP
                            // Only funct7=0000000 (normal ops) and 0100000
                            // (SUB/SRA) are valid in base RV32I.
                            if (funct7 != 7'b0000000 && funct7 != 7'b0100000) begin
                                trap <= 1'b1;
                            end else begin
                                case (funct3)
                                    3'b000: begin
                                        if (funct7 == 7'b0100000) write_rd(rd, rs1_val-rs2_val);
                                        else write_rd(rd, rs1_val+rs2_val);
                                    end
                                    3'b001: if (funct7 == 7'b0000000) write_rd(rd, rs1_val << rs2_val[4:0]); else trap <= 1'b1;
                                    3'b010: if (funct7 == 7'b0000000) write_rd(rd, ($signed(rs1_val) < $signed(rs2_val)) ? 1 : 0); else trap <= 1'b1;
                                    3'b011: if (funct7 == 7'b0000000) write_rd(rd, (rs1_val < rs2_val) ? 1 : 0); else trap <= 1'b1;
                                    3'b100: if (funct7 == 7'b0000000) write_rd(rd, rs1_val ^ rs2_val); else trap <= 1'b1;
                                    3'b101: begin
                                        if (funct7 == 7'b0100000) write_rd(rd, $signed(rs1_val) >>> rs2_val[4:0]);
                                        else if (funct7 == 7'b0000000) write_rd(rd, rs1_val >> rs2_val[4:0]);
                                        else trap <= 1'b1;
                                    end
                                    3'b110: if (funct7 == 7'b0000000) write_rd(rd, rs1_val | rs2_val); else trap <= 1'b1;
                                    3'b111: if (funct7 == 7'b0000000) write_rd(rd, rs1_val & rs2_val); else trap <= 1'b1;
                                    default: trap <= 1'b1;
                                endcase
                            end
                            state <= S_FETCH;
                        end
                        7'b0001111: begin // FENCE
                            if (funct3 == 3'b000) state <= S_FETCH;
                            else begin trap <= 1'b1; state <= S_FETCH; end
                        end
                        7'b1110011: begin // SYSTEM
                            if (instr == 32'h00000073 || instr == 32'h00100073) begin
                                trap <= 1'b1;
                            end else begin
                                trap <= 1'b1;
                            end
                            state <= S_FETCH;
                        end
                        default: begin
                            trap <= 1'b1;
                            state <= S_FETCH;
                        end
                    endcase
                end

                S_MEM: begin
                    if (mem_ready) begin
                        if (mem_is_load)
                            write_rd(mem_rd, load_extend(mem_rdata, mem_load_addr[1:0], mem_funct3));
                        // The interconnect uses a hold state to avoid accepting
                        // one native request twice. Insert one idle cycle so
                        // mem_valid is low before the next request is issued.
                        state <= S_GAP;
                    end
                end

                S_GAP: begin
                    state <= S_FETCH;
                end
                default: state <= S_FETCH;
            endcase
        end
    end
endmodule
