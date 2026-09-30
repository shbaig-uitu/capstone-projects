`timescale 1ns/1ps

module dual_core_tb;

reg clk;
reg reset;

dual_core_top dut(
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

dut.core1.imem.memory[0] = 32'h00700093;
dut.core1.imem.memory[1] = 32'h00300113;
dut.core1.imem.memory[2] = 32'h002081B3;

#100;

$display("CORE 0");
$display("x1 = %h",dut.core0.regs.registers[1]);
$display("x2 = %h",dut.core0.regs.registers[2]);
$display("x3 = %h",dut.core0.regs.registers[3]);

$display("CORE 1");
$display("x1 = %h",dut.core1.regs.registers[1]);
$display("x2 = %h",dut.core1.regs.registers[2]);
$display("x3 = %h",dut.core1.regs.registers[3]);

$finish;

end

endmodule
