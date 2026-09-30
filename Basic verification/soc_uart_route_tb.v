`timescale 1ns/1ps

module soc_uart_route_tb;

reg clk;
reg reset;


// ==================================================
// CORE 0
// ==================================================

reg core0_read;
reg core0_write;

reg [31:0] core0_address;
reg [31:0] core0_write_data;

wire [31:0] core0_read_data;
wire core0_ready;


// ==================================================
// CORE 1
// ==================================================

reg core1_read;
reg core1_write;

reg [31:0] core1_address;
reg [31:0] core1_write_data;

wire [31:0] core1_read_data;
wire core1_ready;


// ==================================================
// UART
// ==================================================

wire uart_tx_line;
reg uart_rx_line;


// ==================================================
// DUT
// ==================================================

mailbox_system dut(

.clk(clk),
.reset(reset),

.core0_read(core0_read),
.core0_write(core0_write),
.core0_address(core0_address),
.core0_write_data(core0_write_data),
.core0_read_data(core0_read_data),
.core0_ready(core0_ready),

.core1_read(core1_read),
.core1_write(core1_write),
.core1_address(core1_address),
.core1_write_data(core1_write_data),
.core1_read_data(core1_read_data),
.core1_ready(core1_ready),

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

core0_read = 0;
core0_write = 0;
core0_address = 0;
core0_write_data = 0;

core1_read = 0;
core1_write = 0;
core1_address = 0;
core1_write_data = 0;

uart_rx_line = 1'b1;


// ==================================================
// RESET
// ==================================================

#20;

reset = 0;

#20;


// ==================================================
// TEST 1
// CORE 0 WRITE -> UART
// ==================================================

$display("");
$display("TEST 1: CORE 0 WRITE TO UART");

@(negedge clk);

core0_address = 32'h00002000;
core0_write_data = 32'h000000A6;
core0_write = 1'b1;


// UART/AXI takes multiple cycles,
// therefore keep request asserted.

while(core0_ready != 1'b1)
    @(negedge clk);


$display("Core0 Ready = %b", core0_ready);
$display("UART TX Data = %h",
         dut.uart_system.uart_slave.tx_data);


core0_write = 1'b0;


if(dut.uart_system.uart_slave.tx_data == 8'hA6)

$display("PASS: Core 0 request reached AXI UART");

else

$display("FAIL: UART did not receive Core 0 data");


@(negedge clk);


// ==================================================
// TEST 2
// CORE 1 READ UART STATUS
// ==================================================

$display("");
$display("TEST 2: CORE 1 READ UART STATUS");

core1_address = 32'h00002004;
core1_read = 1'b1;


while(core1_ready != 1'b1)
    @(negedge clk);


$display("Core1 Ready = %b", core1_ready);
$display("UART Status = %h",
         core1_read_data);


if(core1_read_data[0] == 1'b1)

$display("PASS: Core 1 read UART busy status");

else

$display("NOTE: UART transmission already completed");


core1_read = 1'b0;


@(negedge clk);


// ==================================================
// TEST 3
// MAKE SURE SRAM ROUTING STILL WORKS
// ==================================================

$display("");
$display("TEST 3: SHARED SRAM STILL WORKS");

core0_address = 32'h00000010;
core0_write_data = 32'h12345678;
core0_write = 1'b1;

@(negedge clk);

core0_write = 1'b0;


// Read from Core 1

@(negedge clk);

core1_address = 32'h00000010;
core1_read = 1'b1;

#1;

$display("SRAM Read Data = %h",
         core1_read_data);


if(core1_read_data == 32'h12345678)

$display("PASS: SRAM routing still works");

else

$display("FAIL: SRAM routing broken");


core1_read = 1'b0;


#30;


// ==================================================
// FINISH
// ==================================================

$display("");
$display("SOC UART ROUTING TEST COMPLETE");

$finish;

end

endmodule