`timescale 1ns/1ps

module interconnect_tb;

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

wire mem_read;
wire mem_write;
wire [31:0] mem_address;
wire [31:0] mem_write_data;
reg [31:0] mem_read_data;

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
.mem_read_data(mem_read_data)
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

mem_read_data = 32'h12345678;

#10;
reset = 0;

core0_read = 1;
core0_address = 32'h00000010;

#10;

core0_read = 0;

core1_read = 1;
core1_address = 32'h00000020;

#10;

core1_read = 0;

core0_write = 1;
core0_address = 32'h00000030;
core0_write_data = 32'hAAAAAAAA;

core1_write = 1;
core1_address = 32'h00000040;
core1_write_data = 32'hBBBBBBBB;

#10;

core0_write = 0;
core1_write = 0;

#10;

core0_write = 1;
core0_address = 32'h00000050;
core0_write_data = 32'h11111111;

core1_write = 1;
core1_address = 32'h00000060;
core1_write_data = 32'h22222222;

#10;

core0_write = 0;
core1_write = 0;

#10;

core0_write = 1;
core0_address = 32'h00000070;
core0_write_data = 32'h33333333;

core1_write = 1;
core1_address = 32'h00000080;
core1_write_data = 32'h44444444;

#10;

core0_write = 0;
core1_write = 0;

#20;

$finish;

end

endmodule
