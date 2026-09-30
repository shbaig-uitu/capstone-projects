`timescale 1ns/1ps

module axi_uart_slave_tb;

reg clk;
reg reset;


// AXI Write Address

reg [31:0] S_AXI_AWADDR;
reg S_AXI_AWVALID;
wire S_AXI_AWREADY;


// AXI Write Data

reg [31:0] S_AXI_WDATA;
reg [3:0] S_AXI_WSTRB;
reg S_AXI_WVALID;
wire S_AXI_WREADY;


// AXI Write Response

wire [1:0] S_AXI_BRESP;
wire S_AXI_BVALID;
reg S_AXI_BREADY;


// AXI Read Address

reg [31:0] S_AXI_ARADDR;
reg S_AXI_ARVALID;
wire S_AXI_ARREADY;


// AXI Read Data

wire [31:0] S_AXI_RDATA;
wire [1:0] S_AXI_RRESP;
wire S_AXI_RVALID;
reg S_AXI_RREADY;


// UART

wire uart_tx_line;
reg uart_rx_line;


// ==================================================
// DUT
// ==================================================

axi_uart_slave #(
.CLKS_PER_BIT(8)
)
dut(
.clk(clk),
.reset(reset),

.S_AXI_AWADDR(S_AXI_AWADDR),
.S_AXI_AWVALID(S_AXI_AWVALID),
.S_AXI_AWREADY(S_AXI_AWREADY),

.S_AXI_WDATA(S_AXI_WDATA),
.S_AXI_WSTRB(S_AXI_WSTRB),
.S_AXI_WVALID(S_AXI_WVALID),
.S_AXI_WREADY(S_AXI_WREADY),

.S_AXI_BRESP(S_AXI_BRESP),
.S_AXI_BVALID(S_AXI_BVALID),
.S_AXI_BREADY(S_AXI_BREADY),

.S_AXI_ARADDR(S_AXI_ARADDR),
.S_AXI_ARVALID(S_AXI_ARVALID),
.S_AXI_ARREADY(S_AXI_ARREADY),

.S_AXI_RDATA(S_AXI_RDATA),
.S_AXI_RRESP(S_AXI_RRESP),
.S_AXI_RVALID(S_AXI_RVALID),
.S_AXI_RREADY(S_AXI_RREADY),

.uart_tx_line(uart_tx_line),
.uart_rx_line(uart_rx_line)
);


// Clock

always #5 clk = ~clk;


initial begin

clk = 0;
reset = 1;

S_AXI_AWADDR = 0;
S_AXI_AWVALID = 0;

S_AXI_WDATA = 0;
S_AXI_WSTRB = 4'b1111;
S_AXI_WVALID = 0;

S_AXI_BREADY = 0;

S_AXI_ARADDR = 0;
S_AXI_ARVALID = 0;

S_AXI_RREADY = 0;


// UART idle is HIGH

uart_rx_line = 1'b1;


// --------------------------------------------------
// RESET
// --------------------------------------------------

#20;
reset = 0;

#10;


// ==================================================
// TEST 1
// AXI WRITE UART TX DATA
// ==================================================

$display("");
$display("TEST 1: AXI UART WRITE");


// Write address

S_AXI_AWADDR = 32'h00002000;
S_AXI_AWVALID = 1;

#10;

S_AXI_AWVALID = 0;


// Deliberately send data later

#20;

S_AXI_WDATA = 32'h000000A5;
S_AXI_WSTRB = 4'b1111;
S_AXI_WVALID = 1;

#10;

S_AXI_WVALID = 0;


// Wait for response

#20;

S_AXI_BREADY = 1;

#10;

S_AXI_BREADY = 0;


#10;

$display("TX Data = %h", dut.tx_data);
$display("TX Busy = %b", dut.tx_busy);


if(dut.tx_data == 8'hA5)

$display("PASS: UART TX register received AXI data");

else

$display("FAIL: UART TX register incorrect");


// ==================================================
// TEST 2
// AXI READ UART STATUS
// ==================================================

$display("");
$display("TEST 2: AXI UART STATUS READ");


S_AXI_ARADDR = 32'h00002004;
S_AXI_ARVALID = 1;

#10;

S_AXI_ARVALID = 0;


#10;

S_AXI_RREADY = 1;

#1;

$display("UART Status = %h", S_AXI_RDATA);


if(S_AXI_RRESP == 2'b00)

$display("PASS: UART status read successful");

else

$display("FAIL: UART status read error");


#9;

S_AXI_RREADY = 0;


// --------------------------------------------------
// Finish
// --------------------------------------------------

#20;

$display("");
$display("AXI UART SLAVE TEST COMPLETE");

$finish;

end

endmodule