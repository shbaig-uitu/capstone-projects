`include "rv32i_soc_defines.v"

module rv32i_core (
    input  wire        clk,
    input  wire        rst_n,

    output wire [31:0] imem_addr,
    input  wire [31:0] imem_rdata,

    output wire [31:0] haddr,
    output wire         hwrite,
    output wire [1:0]  hsize,
    output wire [31:0] hwdata,
    output wire         hvalid,
    input  wire [31:0] hrdata,
    input  wire         hready,
    input  wire         hresp
);

    localparam S_IDLE = 1'b0;
    localparam S_WAIT = 1'b1;

    reg [31:0] pc;
    reg        state;

    wire [31:0] instr = imem_rdata;

    wire [4:0]  rs1_addr;
    wire [4:0]  rs2_addr;
    wire [4:0]  rd_addr;
    wire [2:0]  funct3;
    wire [31:0] imm;
    wire [3:0]  alu_op;
    wire        reg_write;
    wire        mem_read;
    wire        mem_write;
    wire        mem_to_reg;
    wire        alu_src;
    wire        branch;
    wire        jump;
    wire        jalr;
    wire        lui;
    wire        auipc;

    decoder u_decoder (
        .instr      (instr),
        .rs1_addr   (rs1_addr),
        .rs2_addr   (rs2_addr),
        .rd_addr    (rd_addr),
        .funct3     (funct3),
        .imm        (imm),
        .alu_op     (alu_op),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .alu_src    (alu_src),
        .branch     (branch),
        .jump       (jump),
        .jalr       (jalr),
        .lui        (lui),
        .auipc      (auipc)
    );

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] rd_data;
    wire        rf_we;

    regfile u_regfile (
        .clk      (clk),
        .rst_n    (rst_n),
        .we       (rf_we),
        .rs1_addr (rs1_addr),
        .rs2_addr (rs2_addr),
        .rd_addr  (rd_addr),
        .rd_data  (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    wire [31:0] alu_operand_a = rs1_data;
    wire [31:0] alu_operand_b = alu_src ? imm : rs2_data;
    wire [31:0] alu_result;
    wire        zero_flag;

    alu u_alu (
        .operand_a (alu_operand_a),
        .operand_b (alu_operand_b),
        .alu_op    (alu_op),
        .result    (alu_result),
        .zero_flag (zero_flag)
    );

    wire is_mem_op   = mem_read | mem_write;
    wire txn_done    = hready;
    wire issue_txn   = is_mem_op & (state == S_IDLE);

    assign hvalid = is_mem_op & ((state == S_IDLE) | (state == S_WAIT));
    assign haddr  = alu_result;
    assign hwrite = mem_write;
    assign hsize  = funct3[1:0];

    reg [31:0] hwdata_r;
    always @(*) begin
        case (funct3[1:0])
            2'b00:   hwdata_r = {4{rs2_data[7:0]}};
            2'b01:   hwdata_r = {2{rs2_data[15:0]}};
            default: hwdata_r = rs2_data;
        endcase
    end
    assign hwdata = hwdata_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
        end else begin
            case (state)
                S_IDLE: state <= (is_mem_op & ~hready) ? S_WAIT : S_IDLE;
                S_WAIT: state <= hready ? S_IDLE : S_WAIT;
                default: state <= S_IDLE;
            endcase
        end
    end

    wire mem_txn_complete = ~is_mem_op | ((state == S_IDLE) & hready) | ((state == S_WAIT) & hready);
    wire pc_advance       = mem_txn_complete;

    assign rf_we = reg_write & mem_txn_complete;

    reg [7:0]  load_byte;
    reg [15:0] load_half;
    always @(*) begin
        case (haddr[1:0])
            2'b00: load_byte = hrdata[7:0];
            2'b01: load_byte = hrdata[15:8];
            2'b10: load_byte = hrdata[23:16];
            2'b11: load_byte = hrdata[31:24];
        endcase
        case (haddr[1])
            1'b0: load_half = hrdata[15:0];
            1'b1: load_half = hrdata[31:16];
        endcase
    end

    reg [31:0] load_data;
    always @(*) begin
        case (funct3)
            3'b000:  load_data = {{24{load_byte[7]}},  load_byte};
            3'b001:  load_data = {{16{load_half[15]}}, load_half};
            3'b010:  load_data = hrdata;
            3'b100:  load_data = {24'h00_0000, load_byte};
            3'b101:  load_data = {16'h0000,    load_half};
            default: load_data = hrdata;
        endcase
    end

    wire branch_taken =
        branch & (
            ((funct3 == 3'b000) &  zero_flag) |
            ((funct3 == 3'b001) & ~zero_flag) |
            ((funct3 == 3'b100) &  alu_result[0]) |
            ((funct3 == 3'b101) & ~alu_result[0]) |
            ((funct3 == 3'b110) &  alu_result[0]) |
            ((funct3 == 3'b111) & ~alu_result[0])
        );

    wire [31:0] jalr_target = (rs1_data + imm) & 32'hFFFF_FFFE;
    wire [31:0] pc_plus_4   = pc + 32'd4;
    wire [31:0] pc_plus_imm = pc + imm;

    wire [31:0] next_pc =
        branch_taken       ? pc_plus_imm :
        (jump &  jalr)     ? jalr_target :
        (jump & ~jalr)     ? pc_plus_imm :
                              pc_plus_4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0000_0000;
        end else if (pc_advance) begin
            pc <= next_pc;
        end
    end

    assign imem_addr = pc;

    wire [31:0] rd_data_sel =
        lui        ? imm :
        auipc      ? alu_result :
        jump       ? pc_plus_4 :
        mem_to_reg ? load_data :
                     alu_result;

    assign rd_data = rd_data_sel;

endmodule
