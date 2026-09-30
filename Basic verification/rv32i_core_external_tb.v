`timescale 1ns/1ps

module rv32i_core_external_tb;

reg clk;
reg reset;

wire mem_read;
wire mem_write;
wire [31:0] mem_address;
wire [31:0] mem_write_data;
reg [31:0] mem_read_data;

reg [31:0] memory [0:255];

rv32i_core dut(
.clk(clk),
.reset(reset),
.mem_read(mem_read),
.mem_write(mem_write),
.mem_address(mem_address),
.mem_write_data(mem_write_data),
.mem_read_data(mem_read_data)
);

always #5 clk = ~clk;

always @(*) begin
if(mem_read)
mem_read_data = memory[mem_address[9:2]];
else
mem_read_data = 32'b0;
end

always @(posedge clk) begin
if(mem_write)
memory[mem_address[9:2]] <= mem_write_data;
end

initial begin

clk = 0;
reset = 1;
mem_read_data = 0;

#10;
reset = 0;

dut.imem.memory[0] = 32'h00500093;
dut.imem.memory[1] = 32'h00A00113;
dut.imem.memory[2] = 32'h002081B3;
dut.imem.memory[3] = 32'h00302023;
dut.imem.memory[4] = 32'h00002203;

#100;

$display("x1 = %h",dut.regs.registers[1]);
$display("x2 = %h",dut.regs.registers[2]);
$display("x3 = %h",dut.regs.registers[3]);
$display("x4 = %h",dut.regs.registers[4]);
$display("memory[0] = %h",memory[0]);

if(dut.regs.registers[1] == 32'h00000005 &&
dut.regs.registers[2] == 32'h0000000A &&
dut.regs.registers[3] == 32'h0000000F &&
dut.regs.registers[4] == 32'h0000000F &&
memory[0] == 32'h0000000F)
$display("PASS: External memory interface works correctly");

else
$display("FAIL: External memory interface error");

$finish;

end

endmodule