module axi_uart_slave #(
parameter CLKS_PER_BIT = 8
)(
input clk,
input reset,

// --------------------------------------------------
// AXI4-Lite Write Address Channel
// --------------------------------------------------

input [31:0] S_AXI_AWADDR,
input S_AXI_AWVALID,
output reg S_AXI_AWREADY,

// --------------------------------------------------
// AXI4-Lite Write Data Channel
// --------------------------------------------------

input [31:0] S_AXI_WDATA,
input [3:0] S_AXI_WSTRB,
input S_AXI_WVALID,
output reg S_AXI_WREADY,

// --------------------------------------------------
// AXI4-Lite Write Response Channel
// --------------------------------------------------

output reg [1:0] S_AXI_BRESP,
output reg S_AXI_BVALID,
input S_AXI_BREADY,

// --------------------------------------------------
// AXI4-Lite Read Address Channel
// --------------------------------------------------

input [31:0] S_AXI_ARADDR,
input S_AXI_ARVALID,
output reg S_AXI_ARREADY,

// --------------------------------------------------
// AXI4-Lite Read Data Channel
// --------------------------------------------------

output reg [31:0] S_AXI_RDATA,
output reg [1:0] S_AXI_RRESP,
output reg S_AXI_RVALID,
input S_AXI_RREADY,

// --------------------------------------------------
// UART Pins
// --------------------------------------------------

output uart_tx_line,
input uart_rx_line

);


// ==================================================
// UART Address Map
// ==================================================

localparam UART_TX_DATA = 32'h00002000;
localparam UART_STATUS  = 32'h00002004;
localparam UART_RX_DATA = 32'h00002008;


// ==================================================
// Internal UART Signals
// ==================================================

reg [7:0] tx_data;
reg tx_send;

wire tx_busy;

wire [7:0] rx_data;
wire rx_done;

wire parity_error;
wire frame_error;

reg rx_valid;


// ==================================================
// AXI Write Storage
// ==================================================

reg [31:0] write_address;
reg [31:0] write_data;
reg [3:0] write_strobe;

reg address_received;
reg data_received;


// ==================================================
// UART Transmitter
// ==================================================

uart_tx #(
.CLKS_PER_BIT(CLKS_PER_BIT)
)
uart_tx_unit(
.clk(clk),
.reset(reset),
.send(tx_send),
.data_in(tx_data),
.tx_line(uart_tx_line),
.busy(tx_busy)
);


// ==================================================
// UART Receiver
// ==================================================

uart_rx #(
.CLKS_PER_BIT(CLKS_PER_BIT)
)
uart_rx_unit(
.clk(clk),
.reset(reset),
.rx_line(uart_rx_line),
.rx_data(rx_data),
.rx_done(rx_done),
.parity_err(parity_error),
.frame_err(frame_error)
);


// ==================================================
// RX VALID FLAG
// ==================================================

always @(posedge clk) begin

if(reset) begin

rx_valid <= 1'b0;

end

else begin

// New UART byte received

if(rx_done)
rx_valid <= 1'b1;


// Reading RX DATA consumes the received byte

if(S_AXI_RVALID &&
   S_AXI_RREADY &&
   S_AXI_ARADDR == UART_RX_DATA)

rx_valid <= 1'b0;

end

end


// ==================================================
// AXI WRITE LOGIC
// ==================================================

always @(posedge clk) begin

if(reset) begin

S_AXI_AWREADY <= 1'b0;
S_AXI_WREADY <= 1'b0;

S_AXI_BRESP <= 2'b00;
S_AXI_BVALID <= 1'b0;

write_address <= 32'b0;
write_data <= 32'b0;
write_strobe <= 4'b0;

address_received <= 1'b0;
data_received <= 1'b0;

tx_data <= 8'b0;
tx_send <= 1'b0;

end

else begin

// Default one-cycle pulse
tx_send <= 1'b0;


// ==================================================
// WRITE ADDRESS CHANNEL
// ==================================================

if(!address_received &&
   !S_AXI_BVALID)

S_AXI_AWREADY <= 1'b1;

else

S_AXI_AWREADY <= 1'b0;


if(S_AXI_AWVALID &&
   S_AXI_AWREADY) begin

write_address <= S_AXI_AWADDR;
address_received <= 1'b1;

end


// ==================================================
// WRITE DATA CHANNEL
// ==================================================

if(!data_received &&
   !S_AXI_BVALID)

S_AXI_WREADY <= 1'b1;

else

S_AXI_WREADY <= 1'b0;


if(S_AXI_WVALID &&
   S_AXI_WREADY) begin

write_data <= S_AXI_WDATA;
write_strobe <= S_AXI_WSTRB;
data_received <= 1'b1;

end


// ==================================================
// EXECUTE WRITE
// ==================================================

if(address_received &&
   data_received &&
   !S_AXI_BVALID) begin

// Default = AXI OKAY
S_AXI_BRESP <= 2'b00;


// --------------------------------------------------
// UART TX DATA REGISTER
// --------------------------------------------------

if(write_address == UART_TX_DATA) begin

if(write_strobe[0]) begin

// Only send if UART TX is free

if(!tx_busy) begin

tx_data <= write_data[7:0];
tx_send <= 1'b1;

end

else begin

// UART busy
S_AXI_BRESP <= 2'b10;

end

end

end


// --------------------------------------------------
// Invalid or Read-Only Address
// --------------------------------------------------

else begin

S_AXI_BRESP <= 2'b10;

end


S_AXI_BVALID <= 1'b1;

address_received <= 1'b0;
data_received <= 1'b0;

end


// ==================================================
// WRITE RESPONSE ACCEPTED
// ==================================================

if(S_AXI_BVALID &&
   S_AXI_BREADY) begin

S_AXI_BVALID <= 1'b0;

end

end

end


// ==================================================
// AXI READ LOGIC
// ==================================================

always @(posedge clk) begin

if(reset) begin

S_AXI_ARREADY <= 1'b0;

S_AXI_RDATA <= 32'b0;
S_AXI_RRESP <= 2'b00;
S_AXI_RVALID <= 1'b0;

end

else begin


// ==================================================
// READ ADDRESS READY
// ==================================================

if(!S_AXI_RVALID)

S_AXI_ARREADY <= 1'b1;

else

S_AXI_ARREADY <= 1'b0;


// ==================================================
// READ ADDRESS ACCEPTED
// ==================================================

if(S_AXI_ARVALID &&
   S_AXI_ARREADY) begin

// Default = OKAY

S_AXI_RRESP <= 2'b00;


// --------------------------------------------------
// UART TX DATA REGISTER
// --------------------------------------------------

if(S_AXI_ARADDR == UART_TX_DATA) begin

S_AXI_RDATA <=
{
24'b0,
tx_data
};

end


// --------------------------------------------------
// UART STATUS REGISTER
// --------------------------------------------------

else if(S_AXI_ARADDR == UART_STATUS) begin

S_AXI_RDATA <=
{
28'b0,
frame_error,
parity_error,
rx_valid,
tx_busy
};

end


// --------------------------------------------------
// UART RX DATA REGISTER
// --------------------------------------------------

else if(S_AXI_ARADDR == UART_RX_DATA) begin

S_AXI_RDATA <=
{
24'b0,
rx_data
};

end


// --------------------------------------------------
// INVALID ADDRESS
// --------------------------------------------------

else begin

S_AXI_RDATA <= 32'b0;
S_AXI_RRESP <= 2'b10;

end


S_AXI_RVALID <= 1'b1;

end


// ==================================================
// READ DATA ACCEPTED
// ==================================================

if(S_AXI_RVALID &&
   S_AXI_RREADY) begin

S_AXI_RVALID <= 1'b0;

end

end

end

endmodule