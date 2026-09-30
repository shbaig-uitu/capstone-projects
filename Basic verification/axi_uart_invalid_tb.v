`timescale 1ns/1ps

module axi_uart_invalid_tb;

reg clk;
reg reset;

// ==================================================
// AXI WRITE SIGNALS
// ==================================================

reg  [31:0] S_AXI_AWADDR;
reg         S_AXI_AWVALID;
wire        S_AXI_AWREADY;

reg  [31:0] S_AXI_WDATA;
reg  [3:0]  S_AXI_WSTRB;
reg         S_AXI_WVALID;
wire        S_AXI_WREADY;

wire [1:0]  S_AXI_BRESP;
wire        S_AXI_BVALID;
reg         S_AXI_BREADY;


// ==================================================
// AXI READ SIGNALS
// ==================================================

reg  [31:0] S_AXI_ARADDR;
reg         S_AXI_ARVALID;
wire        S_AXI_ARREADY;

wire [31:0] S_AXI_RDATA;
wire [1:0]  S_AXI_RRESP;
wire        S_AXI_RVALID;
reg         S_AXI_RREADY;


// ==================================================
// UART
// ==================================================

wire uart_tx_line;
reg  uart_rx_line;


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

S_AXI_AWADDR  = 0;
S_AXI_AWVALID = 0;

S_AXI_WDATA   = 0;
S_AXI_WSTRB   = 4'b1111;
S_AXI_WVALID  = 0;

S_AXI_BREADY  = 0;

S_AXI_ARADDR  = 0;
S_AXI_ARVALID = 0;

S_AXI_RREADY  = 0;

// UART idle
uart_rx_line = 1'b1;


// ==================================================
// RESET
// ==================================================

#20;
reset = 0;

#20;


// ==================================================
// TEST 1: INVALID AXI READ
// ==================================================

$display("");
$display("TEST 1: INVALID AXI READ");


// Use address outside UART registers

@(negedge clk);

S_AXI_ARADDR  = 32'h00003000;
S_AXI_ARVALID = 1'b1;


// Wait for slave ready

while(S_AXI_ARREADY != 1'b1)
    @(negedge clk);


// Allow address handshake

@(negedge clk);

S_AXI_ARVALID = 1'b0;


// Accept response

S_AXI_RREADY = 1'b1;


while(S_AXI_RVALID != 1'b1)
    @(negedge clk);


$display("Read Address = %h", S_AXI_ARADDR);
$display("Read Data    = %h", S_AXI_RDATA);
$display("RRESP        = %b", S_AXI_RRESP);


if(S_AXI_RRESP == 2'b10)

$display("PASS: Invalid AXI read returned SLVERR");

else

$display("FAIL: Invalid AXI read did not return SLVERR");


@(negedge clk);

S_AXI_RREADY = 1'b0;


@(negedge clk);


// ==================================================
// TEST 2: INVALID AXI WRITE
// ==================================================

$display("");
$display("TEST 2: INVALID AXI WRITE");


// --------------------------------------------------
// Write Address
// --------------------------------------------------

S_AXI_AWADDR  = 32'h00003000;
S_AXI_AWVALID = 1'b1;


while(S_AXI_AWREADY != 1'b1)
    @(negedge clk);


@(negedge clk);

S_AXI_AWVALID = 1'b0;


// --------------------------------------------------
// Write Data
// Deliberately later than address
// --------------------------------------------------

@(negedge clk);

S_AXI_WDATA  = 32'hDEADBEEF;
S_AXI_WSTRB  = 4'b1111;
S_AXI_WVALID = 1'b1;


while(S_AXI_WREADY != 1'b1)
    @(negedge clk);


@(negedge clk);

S_AXI_WVALID = 1'b0;


// --------------------------------------------------
// Wait for write response
// --------------------------------------------------

S_AXI_BREADY = 1'b1;


while(S_AXI_BVALID != 1'b1)
    @(negedge clk);


$display("Write Address = %h", S_AXI_AWADDR);
$display("Write Data    = %h", S_AXI_WDATA);
$display("BRESP         = %b", S_AXI_BRESP);


if(S_AXI_BRESP == 2'b10)

$display("PASS: Invalid AXI write returned SLVERR");

else

$display("FAIL: Invalid AXI write did not return SLVERR");


@(negedge clk);

S_AXI_BREADY = 1'b0;


#20;


// ==================================================
// FINISH
// ==================================================

$display("");
$display("AXI UART INVALID ADDRESS TEST COMPLETE");

$finish;

end

endmodule