module axi_lite_master_bridge(

input clk,
input reset,

// ----------------------------------
// SoC / Interconnect Side
// ----------------------------------

input req_read,
input req_write,

input [31:0] req_address,
input [31:0] req_write_data,

output reg [31:0] resp_read_data,
output reg resp_ready,
output reg resp_error,


// ----------------------------------
// AXI4-Lite Write Address Channel
// ----------------------------------

output reg [31:0] M_AXI_AWADDR,
output reg M_AXI_AWVALID,
input M_AXI_AWREADY,


// ----------------------------------
// AXI4-Lite Write Data Channel
// ----------------------------------

output reg [31:0] M_AXI_WDATA,
output reg [3:0] M_AXI_WSTRB,
output reg M_AXI_WVALID,
input M_AXI_WREADY,


// ----------------------------------
// AXI4-Lite Write Response Channel
// ----------------------------------

input [1:0] M_AXI_BRESP,
input M_AXI_BVALID,
output reg M_AXI_BREADY,


// ----------------------------------
// AXI4-Lite Read Address Channel
// ----------------------------------

output reg [31:0] M_AXI_ARADDR,
output reg M_AXI_ARVALID,
input M_AXI_ARREADY,


// ----------------------------------
// AXI4-Lite Read Data Channel
// ----------------------------------

input [31:0] M_AXI_RDATA,
input [1:0] M_AXI_RRESP,
input M_AXI_RVALID,
output reg M_AXI_RREADY

);


// ==================================================
// State Definitions
// ==================================================

localparam IDLE        = 3'd0;
localparam WRITE       = 3'd1;
localparam WRITE_RESP  = 3'd2;
localparam READ_ADDR   = 3'd3;
localparam READ_DATA   = 3'd4;

// New:
// One-cycle gap after a completed transaction.
// This prevents the same level-held core request
// from being accepted again immediately.
localparam TURNAROUND  = 3'd5;

reg [2:0] state;


// ==================================================
// Write Handshake Tracking
// ==================================================

reg aw_done;
reg w_done;


// ==================================================
// Sequential Logic
// ==================================================

always @(posedge clk) begin

if(reset) begin

state <= IDLE;

M_AXI_AWADDR <= 32'b0;
M_AXI_AWVALID <= 1'b0;

M_AXI_WDATA <= 32'b0;
M_AXI_WSTRB <= 4'b1111;
M_AXI_WVALID <= 1'b0;

M_AXI_BREADY <= 1'b0;

M_AXI_ARADDR <= 32'b0;
M_AXI_ARVALID <= 1'b0;

M_AXI_RREADY <= 1'b0;

resp_read_data <= 32'b0;
resp_ready <= 1'b0;
resp_error <= 1'b0;

aw_done <= 1'b0;
w_done <= 1'b0;

end

else begin

// ==================================================
// Default pulse outputs
// ==================================================

resp_ready <= 1'b0;
resp_error <= 1'b0;


// ==================================================
// State Machine
// ==================================================

case(state)


// --------------------------------------------------
// IDLE
// --------------------------------------------------

IDLE: begin

M_AXI_AWVALID <= 1'b0;
M_AXI_WVALID <= 1'b0;
M_AXI_BREADY <= 1'b0;

M_AXI_ARVALID <= 1'b0;
M_AXI_RREADY <= 1'b0;

aw_done <= 1'b0;
w_done <= 1'b0;


// WRITE request gets priority if both asserted

if(req_write) begin

M_AXI_AWADDR <= req_address;
M_AXI_WDATA <= req_write_data;
M_AXI_WSTRB <= 4'b1111;

M_AXI_AWVALID <= 1'b1;
M_AXI_WVALID <= 1'b1;

state <= WRITE;

end

else if(req_read) begin

M_AXI_ARADDR <= req_address;
M_AXI_ARVALID <= 1'b1;

state <= READ_ADDR;

end

end


// --------------------------------------------------
// WRITE
// --------------------------------------------------

WRITE: begin

// Address handshake

if(M_AXI_AWVALID && M_AXI_AWREADY) begin

M_AXI_AWVALID <= 1'b0;
aw_done <= 1'b1;

end


// Data handshake

if(M_AXI_WVALID && M_AXI_WREADY) begin

M_AXI_WVALID <= 1'b0;
w_done <= 1'b1;

end


// Both handshakes may occur in different cycles.
// These conditions also handle completion happening
// on the current cycle.

if(
(aw_done || (M_AXI_AWVALID && M_AXI_AWREADY))
&&
(w_done || (M_AXI_WVALID && M_AXI_WREADY))
) begin

M_AXI_BREADY <= 1'b1;
state <= WRITE_RESP;

end

end


// --------------------------------------------------
// WRITE RESPONSE
// --------------------------------------------------

WRITE_RESP: begin

if(M_AXI_BVALID && M_AXI_BREADY) begin

M_AXI_BREADY <= 1'b0;

resp_ready <= 1'b1;

if(M_AXI_BRESP != 2'b00)
    resp_error <= 1'b1;

// IMPORTANT:
// Do not go directly back to IDLE.
// Give core one clock to update its PC/request/address.

state <= TURNAROUND;

end

end


// --------------------------------------------------
// READ ADDRESS
// --------------------------------------------------

READ_ADDR: begin

if(M_AXI_ARVALID && M_AXI_ARREADY) begin

M_AXI_ARVALID <= 1'b0;
M_AXI_RREADY <= 1'b1;

state <= READ_DATA;

end

end


// --------------------------------------------------
// READ DATA
// --------------------------------------------------

READ_DATA: begin

if(M_AXI_RVALID && M_AXI_RREADY) begin

resp_read_data <= M_AXI_RDATA;

M_AXI_RREADY <= 1'b0;

resp_ready <= 1'b1;

if(M_AXI_RRESP != 2'b00)
    resp_error <= 1'b1;

// IMPORTANT:
// One-cycle turnaround prevents old UART status
// request from being captured again.

state <= TURNAROUND;

end

end


// --------------------------------------------------
// TURNAROUND
// --------------------------------------------------
//
// Wait one complete clock after resp_ready.
// During this cycle the RISC-V core gets time to
// advance PC and present the next address/request.
//
// Next cycle IDLE will accept the fresh request.
//
// This is better than waiting for req_read/req_write
// to become LOW, because two memory instructions may
// be back-to-back.
// --------------------------------------------------

TURNAROUND: begin

M_AXI_AWVALID <= 1'b0;
M_AXI_WVALID <= 1'b0;
M_AXI_BREADY <= 1'b0;

M_AXI_ARVALID <= 1'b0;
M_AXI_RREADY <= 1'b0;

aw_done <= 1'b0;
w_done <= 1'b0;

state <= IDLE;

end


// --------------------------------------------------
// DEFAULT
// --------------------------------------------------

default: begin

state <= IDLE;

M_AXI_AWVALID <= 1'b0;
M_AXI_WVALID <= 1'b0;
M_AXI_BREADY <= 1'b0;

M_AXI_ARVALID <= 1'b0;
M_AXI_RREADY <= 1'b0;

aw_done <= 1'b0;
w_done <= 1'b0;

end

endcase

end

end

endmodule