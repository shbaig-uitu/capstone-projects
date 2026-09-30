`timescale 1ns/1ps

module rv32i_core_tb;

reg clk;
reg reset;

rv32i_core dut(
.clk(clk),
.reset(reset)
);

always #5 clk = ~clk;

initial begin

clk = 0;
reset = 1;

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
$display("memory[0] = %h",dut.dmem.memory[0]);

$finish;

end

endmodule
