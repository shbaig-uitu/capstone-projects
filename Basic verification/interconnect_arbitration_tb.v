`timescale 1ns/1ps

module interconnect_arbitration_tb;

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

// Shared Memory Interface
wire mem_read;
wire mem_write;
wire [31:0] mem_address;
wire [31:0] mem_write_data;

reg [31:0] mem_read_data;

// Mailbox Interface
wire mailbox_read;
wire mailbox_write;
wire [31:0] mailbox_address;
wire [31:0] mailbox_write_data;

reg [31:0] mailbox_read_data;


// DUT
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
.mailbox_read_data(mailbox_read_data)
);


// Clock
always #5 clk = ~clk;


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


// Reset
#10;
reset = 0;


// --------------------------------------------------
// Both cores request at the SAME TIME
// --------------------------------------------------

#5;

core0_read = 1;
core0_address = 32'h00000010;

core1_read = 1;
core1_address = 32'h00000020;

#1;

$display("FIRST ARBITRATION");

$display("core0_ready = %b", core0_ready);
$display("core1_ready = %b", core1_ready);
$display("mem_address = %h", mem_address);


// Initial last_grant = 0
// Therefore Core 1 should win first

if(core0_ready == 0 &&
   core1_ready == 1 &&
   mem_address == 32'h00000020)

$display("PASS: Core 1 received first grant");

else
$display("FAIL: First arbitration");


// Wait for clock so round-robin state updates
#9;


// --------------------------------------------------
// Requests still active
// Now Core 0 should receive grant
// --------------------------------------------------

#1;

$display("");
$display("SECOND ARBITRATION");

$display("core0_ready = %b", core0_ready);
$display("core1_ready = %b", core1_ready);
$display("mem_address = %h", mem_address);


if(core0_ready == 1 &&
   core1_ready == 0 &&
   mem_address == 32'h00000010)

$display("PASS: Core 0 received second grant");

else
$display("FAIL: Second arbitration");


// Remove requests
core0_read = 0;
core1_read = 0;


#10;

$display("");
$display("ARBITRATION TEST COMPLETE");

$finish;

end

endmodule