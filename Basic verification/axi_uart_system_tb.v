`timescale 1ns/1ps

module axi_uart_system_tb;

reg clk;
reg reset;


// ==================================================
// SIMPLE REQUEST INTERFACE
// ==================================================

reg req_read;
reg req_write;

reg [31:0] req_address;
reg [31:0] req_write_data;

wire [31:0] resp_read_data;
wire resp_ready;
wire resp_error;


// ==================================================
// UART
// ==================================================

wire uart_tx_line;
reg uart_rx_line;


// ==================================================
// CAPTURED RESULTS
// ==================================================

reg [31:0] last_read_data;
reg last_error;


// ==================================================
// DUT
// ==================================================

axi_uart_system #(
.CLKS_PER_BIT(8)
)
dut(

.clk(clk),
.reset(reset),

.req_read(req_read),
.req_write(req_write),

.req_address(req_address),
.req_write_data(req_write_data),

.resp_read_data(resp_read_data),
.resp_ready(resp_ready),
.resp_error(resp_error),

.uart_tx_line(uart_tx_line),
.uart_rx_line(uart_rx_line)

);


// ==================================================
// CLOCK
// ==================================================

always #5 clk = ~clk;


// ==================================================
// SIMPLE WRITE TASK
// ==================================================

task simple_write;

input [31:0] address;
input [31:0] data;

begin

@(negedge clk);

req_address = address;
req_write_data = data;
req_write = 1'b1;


// Wait for completion

while(resp_ready != 1'b1)
    @(negedge clk);


// Capture response immediately

last_error = resp_error;

$display("Write Address = %h", address);
$display("Write Data    = %h", data);
$display("Write Error   = %b", resp_error);


// IMPORTANT:
// Remove request immediately.
// Do not leave it HIGH for another posedge.

req_write = 1'b0;


// Allow bridge to settle

@(negedge clk);

end

endtask


// ==================================================
// SIMPLE READ TASK
// ==================================================

task simple_read;

input [31:0] address;

begin

@(negedge clk);

req_address = address;
req_read = 1'b1;


// Wait for completion

while(resp_ready != 1'b1)
    @(negedge clk);


// Capture response immediately

last_read_data = resp_read_data;
last_error = resp_error;

$display("Read Address  = %h", address);
$display("Read Data     = %h", resp_read_data);
$display("Read Error    = %b", resp_error);


// IMPORTANT:
// Remove request immediately.

req_read = 1'b0;


// Allow bridge to settle

@(negedge clk);

end

endtask


// ==================================================
// TEST
// ==================================================

initial begin

clk = 0;
reset = 1;

req_read = 0;
req_write = 0;

req_address = 0;
req_write_data = 0;

last_read_data = 0;
last_error = 0;


// UART idle HIGH

uart_rx_line = 1'b1;


// ==================================================
// RESET
// ==================================================

#20;

reset = 0;

#20;


// ==================================================
// TEST 1:
// SIMPLE INTERFACE -> AXI -> UART TX
// ==================================================

$display("");
$display("TEST 1: SIMPLE REQUEST TO UART TX");

simple_write(
32'h00002000,
32'h0000005A
);


$display("UART TX Data = %h",
         dut.uart_slave.tx_data);


if(dut.uart_slave.tx_data == 8'h5A)

$display("PASS: AXI UART system received TX data");

else

$display("FAIL: UART TX data incorrect");


if(last_error == 1'b0)

$display("PASS: UART write completed without error");

else

$display("FAIL: UART write returned error");


// ==================================================
// TEST 2:
// READ UART STATUS
// ==================================================

$display("");
$display("TEST 2: READ UART STATUS THROUGH AXI BRIDGE");

simple_read(
32'h00002004
);


$display("UART Status = %h",
         last_read_data);


if(last_error == 1'b0)

$display("PASS: UART status read completed without error");

else

$display("FAIL: UART status read returned error");


// Status bit 0 = TX busy

if(last_read_data[0] == 1'b1)

$display("PASS: UART TX busy status is set");

else

$display("NOTE: UART TX busy is already clear");


// ==================================================
// TEST 3:
// INVALID READ ADDRESS
// ==================================================

$display("");
$display("TEST 3: INVALID ADDRESS ERROR PROPAGATION");

simple_read(
32'h00003000
);


if(last_error == 1'b1)

$display("PASS: AXI SLVERR propagated to simple interface");

else

$display("FAIL: AXI error was not propagated");


if(last_read_data == 32'h00000000)

$display("PASS: Invalid read returned zero data");

else

$display("FAIL: Invalid read data incorrect");


// ==================================================
// FINISH
// ==================================================

#30;

$display("");
$display("AXI UART SYSTEM INTEGRATION TEST COMPLETE");

$finish;

end

endmodule