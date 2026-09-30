`timescale 1ns/1ps

module dual_core_uart_tb;

reg clk;
reg reset;

wire uart_tx_line;
reg uart_rx_line;


// ==================================================
// DUT
// ==================================================

dual_core_soc dut(
.clk(clk),
.reset(reset),

.uart_tx_line(uart_tx_line),
.uart_rx_line(uart_rx_line)
);


// ==================================================
// CLOCK
// ==================================================

always #5 clk = ~clk;


// ==================================================
// TEST
// ==================================================

initial begin

clk = 0;
reset = 1;

// UART idle HIGH
uart_rx_line = 1'b1;


// ==================================================
// CORE 0 PROGRAM
//
// x5 = 0x2000
// x3 = 0x5A
// SW x3,0(x5)
// ==================================================

dut.core0.imem.memory[0] = 32'h000022B7;
dut.core0.imem.memory[1] = 32'h05A00193;
dut.core0.imem.memory[2] = 32'h0032A023;


// NOPs

dut.core0.imem.memory[3] = 32'h00000013;
dut.core0.imem.memory[4] = 32'h00000013;
dut.core0.imem.memory[5] = 32'h00000013;


// ==================================================
// CORE 1 PROGRAM
//
// x5 = 0x2000
// poll UART STATUS at 0x2004
// ==================================================

dut.core1.imem.memory[0] = 32'h000022B7;
dut.core1.imem.memory[1] = 32'h0042A303;
dut.core1.imem.memory[2] = 32'hFE030EE3;


// ==================================================
// RESET RELEASE
// ==================================================

#20;

reset = 0;


// Give enough time for AXI transaction
// and UART transmitter to start

#250;


// ==================================================
// RESULTS
// ==================================================

$display("");
$display("CORE 0");
$display("x3 = %h", dut.core0.regs.registers[3]);
$display("x5 = %h", dut.core0.regs.registers[5]);

$display("");
$display("CORE 1");
$display("x5 = %h", dut.core1.regs.registers[5]);
$display("x6 = %h", dut.core1.regs.registers[6]);

$display("");
$display("UART");
$display("TX Data = %h",
dut.system.uart_system.uart_slave.tx_data);

$display("TX Busy = %b",
dut.system.uart_system.uart_slave.tx_busy);


// ==================================================
// CHECK CORE 0
// ==================================================

if(dut.core0.regs.registers[3] == 32'h0000005A)

$display("PASS: Core 0 generated UART data");

else

$display("FAIL: Core 0 data generation");


// ==================================================
// CHECK UART TX REGISTER
// ==================================================

if(dut.system.uart_system.uart_slave.tx_data == 8'h5A)

$display("PASS: Core 0 wrote data through AXI to UART");

else

$display("FAIL: UART did not receive Core 0 data");


// ==================================================
// CHECK CORE 1 STATUS READ
// ==================================================

if(dut.core1.regs.registers[6][0] == 1'b1)

$display("PASS: Core 1 read UART busy status");

else

$display("FAIL: Core 1 did not observe UART busy status");


#20;

$display("");
$display("DUAL CORE AXI UART TEST COMPLETE");

$finish;

end

endmodule