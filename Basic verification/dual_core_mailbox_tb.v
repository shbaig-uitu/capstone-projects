`timescale 1ns/1ps

module dual_core_mailbox_tb;

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
dut.core0.imem.memory[3] = 32'h000012B7;
dut.core0.imem.memory[4] = 32'h0032A023;

dut.core1.imem.memory[0] = 32'h000012B7;
dut.core1.imem.memory[1] = 32'h0042A303;
dut.core1.imem.memory[2] = 32'hFE600CE3;
dut.core1.imem.memory[3] = 32'h0002A183;

#150;

$display("CORE 0");
$display("x1 = %h",dut.core0.regs.registers[1]);
$display("x2 = %h",dut.core0.regs.registers[2]);
$display("x3 = %h",dut.core0.regs.registers[3]);

$display("CORE 1");
$display("x3 = %h",dut.core1.regs.registers[3]);

if(dut.core0.regs.registers[3] == 32'h0000000F)
$display("PASS: Core 0 generated mailbox data");

else
$display("FAIL: Core 0 calculation error");

if(dut.core1.regs.registers[3] == 32'h0000000F)
$display("PASS: Core 1 received mailbox data");

else
$display("FAIL: Core 1 mailbox communication error");

$finish;

end

endmodule