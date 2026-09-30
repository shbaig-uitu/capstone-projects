`timescale 1ns/1ps

module mailbox_system_tb;

reg clk;
reg reset;

reg core0_read;
reg core0_write;
reg [31:0] core0_address;
reg [31:0] core0_write_data;
wire [31:0] core0_read_data;
wire core0_ready;

reg core1_read;
reg core1_write;
reg [31:0] core1_address;
reg [31:0] core1_write_data;
wire [31:0] core1_read_data;
wire core1_ready;

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
.core1_ready(core1_ready)
);

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

#10;
reset = 0;

core0_write = 1;
core0_address = 32'h00001000;
core0_write_data = 32'hAAAAAAAA;

#10;

core0_write = 0;

core1_read = 1;
core1_address = 32'h00001004;

#10;

if(core1_read_data == 32'h00000001)
$display("PASS: Core 1 sees mailbox status");

else
$display("FAIL: Mailbox status = %h",core1_read_data);

core1_address = 32'h00001000;

#10;

if(core1_read_data == 32'hAAAAAAAA)
$display("PASS: Core 1 received mailbox message");

else
$display("FAIL: Mailbox message = %h",core1_read_data);

core1_address = 32'h00001004;

#10;

if(core1_read_data == 32'h00000000)
$display("PASS: Mailbox message consumed");

else
$display("FAIL: Mailbox status = %h",core1_read_data);

core1_read = 0;

#20;

$finish;

end

endmodule