module rv32i_core(
    input         clk,
    input         reset,

    
    
    

    output [31:0] pc,
    input  [31:0] instruction,

    
    
    

    output        mem_read,
    output        mem_write,
    output [3:0]  mem_write_strobe,
    output [31:0] mem_address,
    output [31:0] mem_write_data,

    input  [31:0] mem_read_data,
    input         mem_ready
);

reg execute_phase;

wire [31:0] next_pc;

wire [31:0] read_data1;
wire [31:0] read_data2;
wire [31:0] immediate;

wire        reg_write_ctrl;
wire        reg_write;

wire        mem_read_ctrl;
wire        mem_write_ctrl;

wire        alu_src;
wire        branch;
wire        jump;
wire        jalr;
wire        lui;
wire        auipc;

wire [1:0]  result_src;
wire [3:0]  alu_control;

wire [1:0] mem_size;
wire       mem_signed;

wire [31:0] alu_input_a;
wire [31:0] alu_input_b;
wire [31:0] alu_result;

wire zero;

wire [31:0] pc_plus_4;
wire [31:0] branch_target;
wire [31:0] jump_target;
wire [31:0] jalr_target;

wire branch_taken;

wire [31:0] write_data;

wire memory_request;
wire memory_wait;

reg [7:0]  selected_byte;
reg [15:0] selected_halfword;

reg [31:0] formatted_load_data;
reg [31:0] formatted_store_data;

reg [3:0] formatted_write_strobe;

always @(posedge clk) begin

    if (reset) begin

        execute_phase <= 1'b0;

    end
    else begin

        
        
        
        
        
        
        

        if (!execute_phase) begin

            execute_phase <= 1'b1;

        end

        
        
        

        else begin

            
            

            if (!memory_wait)
                execute_phase <= 1'b0;

        end

    end

end

program_counter pc_unit(
    .clk     (clk),
    .reset   (reset),

    
    .enable  (execute_phase && !memory_wait),

    .next_pc (next_pc),
    .pc      (pc)
);

register_file regs(
    .clk        (clk),
    .reset      (reset),

    .reg_write  (reg_write),

    .rs1        (instruction[19:15]),
    .rs2        (instruction[24:20]),
    .rd         (instruction[11:7]),

    .write_data (write_data),

    .read_data1 (read_data1),
    .read_data2 (read_data2)
);

immediate_generator imm_gen(
    .instruction (instruction),
    .immediate   (immediate)
);

control_unit control(
    .opcode      (instruction[6:0]),
    .funct3      (instruction[14:12]),
    .funct7      (instruction[30]),

    .reg_write   (reg_write_ctrl),

    .mem_read    (mem_read_ctrl),
    .mem_write   (mem_write_ctrl),

    .alu_src     (alu_src),

    .branch      (branch),
    .jump        (jump),
    .jalr        (jalr),

    .lui         (lui),
    .auipc       (auipc),

    .result_src  (result_src),
    .alu_control (alu_control),

    .mem_size    (mem_size),
    .mem_signed  (mem_signed)
);

assign alu_input_a =
    auipc ? pc : read_data1;

assign alu_input_b =
    alu_src ? immediate : read_data2;

alu alu_unit(
    .a           (alu_input_a),
    .b           (alu_input_b),
    .alu_control (alu_control),

    .result      (alu_result),
    .zero        (zero)
);

always @(*) begin

    case (alu_result[1:0])

        2'b00:
            selected_byte = mem_read_data[7:0];

        2'b01:
            selected_byte = mem_read_data[15:8];

        2'b10:
            selected_byte = mem_read_data[23:16];

        2'b11:
            selected_byte = mem_read_data[31:24];

        default:
            selected_byte = 8'b0;

    endcase

end

always @(*) begin

    case (alu_result[1])

        1'b0:
            selected_halfword = mem_read_data[15:0];

        1'b1:
            selected_halfword = mem_read_data[31:16];

        default:
            selected_halfword = 16'b0;

    endcase

end

always @(*) begin

    case (mem_size)

        
        
        

        2'b00: begin

            if (mem_signed)

                formatted_load_data =
                    {{24{selected_byte[7]}},
                     selected_byte};

            else

                formatted_load_data =
                    {24'b0,
                     selected_byte};

        end

        
        
        

        2'b01: begin

            if (mem_signed)

                formatted_load_data =
                    {{16{selected_halfword[15]}},
                     selected_halfword};

            else

                formatted_load_data =
                    {16'b0,
                     selected_halfword};

        end

        
        
        

        2'b10: begin

            formatted_load_data =
                mem_read_data;

        end

        default: begin

            formatted_load_data =
                mem_read_data;

        end

    endcase

end

always @(*) begin

    formatted_store_data   = read_data2;
    formatted_write_strobe = 4'b0000;

    case (mem_size)

        
        
        

        2'b00: begin

            case (alu_result[1:0])

                
                2'b00: begin

                    formatted_write_strobe = 4'b0001;

                    formatted_store_data =
                        {
                            24'b0,
                            read_data2[7:0]
                        };

                end

                
                2'b01: begin

                    formatted_write_strobe = 4'b0010;

                    formatted_store_data =
                        {
                            16'b0,
                            read_data2[7:0],
                            8'b0
                        };

                end

                
                2'b10: begin

                    formatted_write_strobe = 4'b0100;

                    formatted_store_data =
                        {
                            8'b0,
                            read_data2[7:0],
                            16'b0
                        };

                end

                
                2'b11: begin

                    formatted_write_strobe = 4'b1000;

                    formatted_store_data =
                        {
                            read_data2[7:0],
                            24'b0
                        };

                end

            endcase

        end

        
        
        

        2'b01: begin

            case (alu_result[1])

                
                1'b0: begin

                    formatted_write_strobe = 4'b0011;

                    formatted_store_data =
                        {
                            16'b0,
                            read_data2[15:0]
                        };

                end

                
                1'b1: begin

                    formatted_write_strobe = 4'b1100;

                    formatted_store_data =
                        {
                            read_data2[15:0],
                            16'b0
                        };

                end

            endcase

        end

        
        
        

        2'b10: begin

            formatted_write_strobe = 4'b1111;
            formatted_store_data   = read_data2;

        end

        default: begin

            formatted_write_strobe = 4'b0000;
            formatted_store_data   = read_data2;

        end

    endcase

end

assign mem_read =
    execute_phase &&
    mem_read_ctrl;

assign mem_write =
    execute_phase &&
    mem_write_ctrl;

assign mem_address =
    alu_result;

assign mem_write_data =
    formatted_store_data;

assign mem_write_strobe =
    (execute_phase &&
     mem_write_ctrl)
        ? formatted_write_strobe
        : 4'b0000;

assign memory_request =
    execute_phase &&
    (mem_read_ctrl | mem_write_ctrl);

assign memory_wait =
    memory_request &&
    !mem_ready;

assign reg_write =
    execute_phase &&
    reg_write_ctrl &&
    (
        !mem_read_ctrl ||
        mem_ready
    );

assign pc_plus_4 =
    pc + 32'd4;

assign branch_target =
    pc + immediate;

assign jump_target =
    pc + immediate;

assign jalr_target =
    (read_data1 + immediate)
    & 32'hFFFFFFFE;

assign branch_taken =
    branch &&
    (

        
        (
            (instruction[14:12] == 3'b000) &&
            (read_data1 == read_data2)
        )

        ||

        
        (
            (instruction[14:12] == 3'b001) &&
            (read_data1 != read_data2)
        )

        ||

        
        (
            (instruction[14:12] == 3'b100) &&
            ($signed(read_data1) <
             $signed(read_data2))
        )

        ||

        
        (
            (instruction[14:12] == 3'b101) &&
            ($signed(read_data1) >=
             $signed(read_data2))
        )

        ||

        
        (
            (instruction[14:12] == 3'b110) &&
            (read_data1 < read_data2)
        )

        ||

        
        (
            (instruction[14:12] == 3'b111) &&
            (read_data1 >= read_data2)
        )

    );

assign next_pc =
    jalr
        ? jalr_target
        :
    jump
        ? jump_target
        :
    branch_taken
        ? branch_target
        :
          pc_plus_4;

assign write_data =

    (result_src == 2'b00)
        ? alu_result

    : (result_src == 2'b01)
        ? formatted_load_data

    : (result_src == 2'b10)
        ? pc_plus_4

    :
        immediate;

endmodule

