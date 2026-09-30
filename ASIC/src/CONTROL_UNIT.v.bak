module control_unit(
  instruction,
  reg_write,
  op_b_sel,
  rs2_addr,
  rs1_addr,
  rd_addr,
  imm,
  alu_op,
  rd_sel,
  mem_read,
  branch,
  jump,
  jalr,
  auipc,
  mem_write
  );
  input wire [31:0] instruction; 
  output reg             branch;
  output reg               jump;
  output reg               jalr;
  output reg              auipc;
  output reg          reg_write;
  output reg [31:0]         imm;
  output reg           op_b_sel;
  output reg [4:0]       alu_op;
  output reg [4:0]     rs1_addr;
  output reg [4:0]     rs2_addr;
  output reg [4:0]      rd_addr;
  output reg             rd_sel;
  output reg           mem_read;
  output reg          mem_write;
  always @(*)begin
    branch=0;
    jump=0;
    jalr=0;
    auipc=0;
    reg_write=0;
    op_b_sel=0;
    rd_sel=0;
    mem_read=0;
    mem_write=0;
    imm=32'b0;
    alu_op=5'b0;
    rs1_addr=5'b0;
    rs2_addr=5'b0;
    rd_addr=5'b0;
    if(instruction[6:0]== 7'b0110011)begin//r_type
        rs1_addr = instruction[19:15];
        rs2_addr = instruction[24:20];
        rd_addr  = instruction[11:7];
        reg_write=1;
        op_b_sel=0;
        rd_sel=1;
        case(instruction[14:12]) // selection based on func3
          3'b000 : alu_op = (instruction[30]) ? 5'b00001: 5'b00000;// sub//add
          3'b001 : alu_op = 5'b00010;//sll
          3'b010 : alu_op = 5'b01000;//slt
          3'b011 : alu_op = 5'b01001;//sltu
          3'b100 : alu_op = 5'b00111;//xor
          3'b101 : alu_op = (instruction[30]) ? 5'b00100 : 5'b00011;//sra//srl
          3'b110 : alu_op = 5'b00110;//or
          3'b111 : alu_op = 5'b00101;//and
          default : alu_op = 5'b00000; // Handle any unsupported cases
        endcase
    end
    else if(instruction[6:0]==7'b0010011)begin//i_type
      rs1_addr = instruction[19:15];
      rs2_addr = instruction[24:20];
      imm = instruction[31] ? {20'b1, instruction[31:20]} : {20'b0, instruction[31:20]};
      rd_addr  = instruction[11:7];
      op_b_sel=1;
      rd_sel=1;
        case (instruction[14:12])
          3'b000 : alu_op = 5'b01010;//addi
          3'b001 : alu_op = 5'b01011;//slli
          3'b010 : alu_op = 5'b01110;//slti
          3'b011 : alu_op = 5'b01111;//sltui
          3'b100 : alu_op = 5'b10001;//xori
          3'b101 : alu_op = (instruction[30]) ? 5'b01101 : 5'b01100;//srai//srli
          3'b110 : alu_op = 5'b10010;//ori
          3'b111 : alu_op = 5'b10000;//andi
          default : alu_op = 5'b01010; // Handle any unsupported cases
      endcase
      reg_write=1;
    end 
    else if(instruction[6:0]==7'b0000011)begin//load
    imm = instruction[31] ? {20'b1, instruction[31:20]} : {20'b0, instruction[31:20]}; 
    rs1_addr = instruction[19:15];
    rd_addr  = instruction[11:7];
    mem_read=1;
    reg_write=1;
    op_b_sel=1;
    rd_sel=0;
    alu_op = 5'b01010;
    end
    else if (instruction[6:0]==7'b0100011)begin//store
      rs1_addr = instruction[19:15];
      rs2_addr = instruction[24:20];
      imm=instruction[31] ? {20'b1, instruction[31:25], instruction[11:7]} : {20'b0, instruction[31:25], instruction[11:7]}; 
      mem_write=1;
      reg_write=0;
      op_b_sel=1;
      alu_op = 5'b01010;
    end
    else if(instruction[6:0]==7'b1100011)begin//branch
      rs1_addr = instruction[19:15];
      rs2_addr = instruction[24:20];
      imm=instruction[31] ? {19'b1,instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0} :{19'b0,instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
      op_b_sel=0;//replicate karna hai
      reg_write=0;
      rd_sel=0;
      branch=1;
      case (instruction[14:12])
          3'b000 : alu_op = 5'b10011;//BEQ
          3'b001 : alu_op = 5'b10100;//BNE
          3'b100 : alu_op = 5'b10101;//BLT
          3'b101 : alu_op = 5'b10110;//BGE
          3'b110 : alu_op = 5'b10111;//BLTU
          3'b111 : alu_op = 5'b11000;//BGEU 
          default : alu_op = 5'b10011; // Handle any unsupported cases
      endcase
    end
    else if(instruction[6:0]==7'b1101111)begin//jal
    rd_addr  = instruction[11:7];
    imm=instruction[31] ? {19'b1,instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0} :{19'b0,instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
    jump=1;
    reg_write=1;
  end
  else if(instruction[6:0]==7'b1100111)begin//jalr
    imm = instruction[31] ? {20'b1, instruction[31:20]} : {20'b0, instruction[31:20]}; 
    rs1_addr = instruction[19:15];
    rd_addr  = instruction[11:7];
    alu_op = 5'b01010;
    op_b_sel=1;
    jalr=1;
    reg_write=1;
  end
  else if(instruction[6:0]==7'b0110111)begin//lui 
  rd_addr  = instruction[11:7];
  imm = {instruction[31:12], 12'b0};
  alu_op = 5'b01010;
  rs1_addr = 5'b0000;
  op_b_sel=1;
  rd_sel=1;
  reg_write=1;
  end
  else if(instruction[6:0]==7'b0010111)begin//auipc 
  rd_addr  = instruction[11:7];
  imm = {instruction[31:12], 12'b0};
  alu_op = 5'b01010;
  auipc=1;
  rd_sel=1;
  op_b_sel=1;
  reg_write=1;
  rs1_addr = 5'b0000;
  end
  end   
endmodule
