`timescale 1ns/1ps

module dual_core_soc_tb;

reg clk;
reg reset;

dual_core_soc dut(
.clk(clk),
.reset(reset)
);

always #5 clk = ~clk;

initial begin

clk = 0;
reset = 1;

#10;
reset = 0;

dut.core0.imem.memory[0] = 32'h00500093;
dut.core0.imem.memory[1] = 32'h00A00113;
dut.core0.imem.memory[2] = 32'h002081B3;
dut.core0.imem.memory[3] = 32'h00302023;

dut.core1.imem.memory[0] = 32'h00002183;
dut.core1.imem.memory[1] = 32'h00118213;

#100;

$display("CORE 0");
$display("x1 = %h",dut.core0.regs.registers[1]);
$display("x2 = %h",dut.core0.regs.registers[2]);
$display("x3 = %h",dut.core0.regs.registers[3]);

$display("CORE 1");
$display("x3 = %h",dut.core1.regs.registers[3]);
$display("x4 = %h",dut.core1.regs.registers[4]);

if(dut.core0.regs.registers[1] == 32'h00000005 &&
dut.core0.regs.registers[2] == 32'h0000000A &&
dut.core0.regs.registers[3] == 32'h0000000F)
$display("PASS: Core 0 executed correctly");

else
$display("FAIL: Core 0 execution error");

if(dut.core1.regs.registers[3] == 32'h0000000F)
$display("PASS: Core 1 received shared data");

else
$display("FAIL: Core 1 shared-memory communication error");

$finish;

end

endmodule