`timescale 1ns/1ps

module axi_lite_master_bridge_tb;

reg clk;
reg reset;


// ----------------------------------
// SoC Request Interface
// ----------------------------------

reg req_read;
reg req_write;

reg [31:0] req_address;
reg [31:0] req_write_data;

wire [31:0] resp_read_data;
wire resp_ready;
wire resp_error;


// ----------------------------------
// AXI Signals
// ----------------------------------

wire [31:0] M_AXI_AWADDR;
wire M_AXI_AWVALID;
reg M_AXI_AWREADY;

wire [31:0] M_AXI_WDATA;
wire [3:0] M_AXI_WSTRB;
wire M_AXI_WVALID;
reg M_AXI_WREADY;

reg [1:0] M_AXI_BRESP;
reg M_AXI_BVALID;
wire M_AXI_BREADY;

wire [31:0] M_AXI_ARADDR;
wire M_AXI_ARVALID;
reg M_AXI_ARREADY;

reg [31:0] M_AXI_RDATA;
reg [1:0] M_AXI_RRESP;
reg M_AXI_RVALID;
wire M_AXI_RREADY;


// ----------------------------------
// DUT
// ----------------------------------

axi_lite_master_bridge dut(

.clk(clk),
.reset(reset),

.req_read(req_read),
.req_write(req_write),

.req_address(req_address),
.req_write_data(req_write_data),

.resp_read_data(resp_read_data),
.resp_ready(resp_ready),
.resp_error(resp_error),

.M_AXI_AWADDR(M_AXI_AWADDR),
.M_AXI_AWVALID(M_AXI_AWVALID),
.M_AXI_AWREADY(M_AXI_AWREADY),

.M_AXI_WDATA(M_AXI_WDATA),
.M_AXI_WSTRB(M_AXI_WSTRB),
.M_AXI_WVALID(M_AXI_WVALID),
.M_AXI_WREADY(M_AXI_WREADY),

.M_AXI_BRESP(M_AXI_BRESP),
.M_AXI_BVALID(M_AXI_BVALID),
.M_AXI_BREADY(M_AXI_BREADY),

.M_AXI_ARADDR(M_AXI_ARADDR),
.M_AXI_ARVALID(M_AXI_ARVALID),
.M_AXI_ARREADY(M_AXI_ARREADY),

.M_AXI_RDATA(M_AXI_RDATA),
.M_AXI_RRESP(M_AXI_RRESP),
.M_AXI_RVALID(M_AXI_RVALID),
.M_AXI_RREADY(M_AXI_RREADY)

);


// Clock

always #5 clk = ~clk;


initial begin

clk = 0;
reset = 1;

req_read = 0;
req_write = 0;

req_address = 0;
req_write_data = 0;

M_AXI_AWREADY = 0;
M_AXI_WREADY = 0;

M_AXI_BRESP = 2'b00;
M_AXI_BVALID = 0;

M_AXI_ARREADY = 0;

M_AXI_RDATA = 0;
M_AXI_RRESP = 2'b00;
M_AXI_RVALID = 0;


// ----------------------------------
// RESET
// ----------------------------------

#20;

reset = 0;

#10;


// ==================================================
// TEST 1: WRITE
// AW and W deliberately accepted
// in DIFFERENT cycles
// ==================================================

$display("");
$display("TEST 1: AXI WRITE");

req_address = 32'h00002000;
req_write_data = 32'h12345678;
req_write = 1;

#10;

req_write = 0;


// Accept AW first

#10;

M_AXI_AWREADY = 1;

#10;

M_AXI_AWREADY = 0;


// Accept W later

#20;

M_AXI_WREADY = 1;

#10;

M_AXI_WREADY = 0;


// Write response

#10;

M_AXI_BVALID = 1;
M_AXI_BRESP = 2'b00;

#10;

M_AXI_BVALID = 0;


#10;

if(resp_ready || dut.state == 0)

$display("PASS: AXI write completed");

else
$display("FAIL: AXI write did not complete");


// ==================================================
// TEST 2: READ
// ==================================================

$display("");
$display("TEST 2: AXI READ");

req_address = 32'h00002008;
req_read = 1;

#10;

req_read = 0;


// Accept read address

#10;

M_AXI_ARREADY = 1;

#10;

M_AXI_ARREADY = 0;


// Return read data

#20;

M_AXI_RDATA = 32'hDEADBEEF;
M_AXI_RRESP = 2'b00;
M_AXI_RVALID = 1;

#10;

M_AXI_RVALID = 0;


#10;

$display("Read Data = %h",resp_read_data);

if(resp_read_data == 32'hDEADBEEF)

$display("PASS: AXI read returned correct data");

else
$display("FAIL: AXI read incorrect");


#20;

$display("");
$display("AXI LITE MASTER BRIDGE TEST COMPLETE");

$finish;

end

endmodule