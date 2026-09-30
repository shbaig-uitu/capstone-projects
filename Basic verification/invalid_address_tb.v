`timescale 1ns/1ps

module invalid_address_tb;

reg clk;
reg reset;

// Core 0
reg core0_read;
reg core0_write;
reg [31:0] core0_address;
reg [31:0] core0_write_data;

wire [31:0] core0_read_data;
wire core0_ready;

// Core 1
reg core1_read;
reg core1_write;
reg [31:0] core1_address;
reg [31:0] core1_write_data;

wire [31:0] core1_read_data;
wire core1_ready;

// Shared Memory
wire mem_read;
wire mem_write;
wire [31:0] mem_address;
wire [31:0] mem_write_data;
reg [31:0] mem_read_data;

// Mailbox
wire mailbox_read;
wire mailbox_write;
wire [31:0] mailbox_address;
wire [31:0] mailbox_write_data;
reg [31:0] mailbox_read_data;

// UART / AXI
wire uart_read;
wire uart_write;
wire [31:0] uart_address;
wire [31:0] uart_write_data;

reg [31:0] uart_read_data;
reg uart_ready;
reg uart_error;


// ==================================================
// DUT
// ==================================================

interconnect dut(
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

.mem_read(mem_read),
.mem_write(mem_write),
.mem_address(mem_address),
.mem_write_data(mem_write_data),
.mem_read_data(mem_read_data),

.mailbox_read(mailbox_read),
.mailbox_write(mailbox_write),
.mailbox_address(mailbox_address),
.mailbox_write_data(mailbox_write_data),
.mailbox_read_data(mailbox_read_data),

.uart_read(uart_read),
.uart_write(uart_write),
.uart_address(uart_address),
.uart_write_data(uart_write_data),
.uart_read_data(uart_read_data),
.uart_ready(uart_ready),
.uart_error(uart_error)
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

mem_read_data = 32'hAAAAAAAA;
mailbox_read_data = 32'hBBBBBBBB;

uart_read_data = 32'hCCCCCCCC;
uart_ready = 1'b0;
uart_error = 1'b0;


// Reset
#10;
reset = 0;


// ==================================================
// TEST 1: INVALID READ
// ==================================================

#5;

core0_address = 32'h00003000;
core0_read = 1;

#1;

$display("INVALID READ TEST");
$display("Address          = %h", core0_address);
$display("Core0 ready      = %b", core0_ready);
$display("Core0 read data  = %h", core0_read_data);

$display("SRAM read        = %b", mem_read);
$display("Mailbox read     = %b", mailbox_read);
$display("UART read        = %b", uart_read);


if(core0_ready == 1 &&
   core0_read_data == 32'h00000000 &&
   mem_read == 0 &&
   mailbox_read == 0 &&
   uart_read == 0)

$display("PASS: Invalid read handled correctly");

else

$display("FAIL: Invalid read handling");


core0_read = 0;


// ==================================================
// TEST 2: INVALID WRITE
// ==================================================

#10;

core0_address = 32'h00003000;
core0_write_data = 32'hDEADBEEF;
core0_write = 1;

#1;

$display("");
$display("INVALID WRITE TEST");

$display("Address          = %h", core0_address);
$display("Write data       = %h", core0_write_data);

$display("Core0 ready      = %b", core0_ready);

$display("SRAM write       = %b", mem_write);
$display("Mailbox write    = %b", mailbox_write);
$display("UART write       = %b", uart_write);


if(core0_ready == 1 &&
   mem_write == 0 &&
   mailbox_write == 0 &&
   uart_write == 0)

$display("PASS: Invalid write blocked correctly");

else

$display("FAIL: Invalid write handling");


core0_write = 0;


#10;

$display("");
$display("INVALID ADDRESS TEST COMPLETE");

$finish;

end

endmodule