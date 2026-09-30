module axi_uart_slave #(
parameter CLKS_PER_BIT = 8
)(
input clk,
input reset,

input [31:0] S_AXI_AWADDR,
input S_AXI_AWVALID,
output reg S_AXI_AWREADY,

input [31:0] S_AXI_WDATA,
input [3:0] S_AXI_WSTRB,
input S_AXI_WVALID,
output reg S_AXI_WREADY,

output reg [1:0] S_AXI_BRESP,
output reg S_AXI_BVALID,
input S_AXI_BREADY,

input [31:0] S_AXI_ARADDR,
input S_AXI_ARVALID,
output reg S_AXI_ARREADY,

output reg [31:0] S_AXI_RDATA,
output reg [1:0] S_AXI_RRESP,
output reg S_AXI_RVALID,
input S_AXI_RREADY,

output uart_tx_line,
input uart_rx_line

);

localparam UART_TX_DATA = 32'h00002000;
localparam UART_STATUS  = 32'h00002004;
localparam UART_RX_DATA = 32'h00002008;

reg [7:0] tx_data;
reg tx_send;

wire tx_busy;

wire [7:0] rx_data;
wire rx_done;

wire parity_error;
wire frame_error;

reg rx_valid;

reg [31:0] write_address;
reg [31:0] write_data;
reg [3:0] write_strobe;

reg address_received;
reg data_received;

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

always @(posedge clk) begin

if(reset) begin

rx_valid <= 1'b0;

end

else begin

if(rx_done)
rx_valid <= 1'b1;

if(S_AXI_RVALID &&
   S_AXI_RREADY &&
   S_AXI_ARADDR == UART_RX_DATA)

rx_valid <= 1'b0;

end

end

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

tx_send <= 1'b0;

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

if(address_received &&
   data_received &&
   !S_AXI_BVALID) begin

S_AXI_BRESP <= 2'b00;

if(write_address == UART_TX_DATA) begin

if(write_strobe[0]) begin

if(!tx_busy) begin

tx_data <= write_data[7:0];
tx_send <= 1'b1;

end

else begin

S_AXI_BRESP <= 2'b10;

end

end

end

else begin

S_AXI_BRESP <= 2'b10;

end

S_AXI_BVALID <= 1'b1;

address_received <= 1'b0;
data_received <= 1'b0;

end

if(S_AXI_BVALID &&
   S_AXI_BREADY) begin

S_AXI_BVALID <= 1'b0;

end

end

end

always @(posedge clk) begin

if(reset) begin

S_AXI_ARREADY <= 1'b0;

S_AXI_RDATA <= 32'b0;
S_AXI_RRESP <= 2'b00;
S_AXI_RVALID <= 1'b0;

end

else begin

if(!S_AXI_RVALID)

S_AXI_ARREADY <= 1'b1;

else

S_AXI_ARREADY <= 1'b0;

if(S_AXI_ARVALID &&
   S_AXI_ARREADY) begin

S_AXI_RRESP <= 2'b00;

if(S_AXI_ARADDR == UART_TX_DATA) begin

S_AXI_RDATA <=
{
24'b0,
tx_data
};

end

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

else if(S_AXI_ARADDR == UART_RX_DATA) begin

S_AXI_RDATA <=
{
24'b0,
rx_data
};

end

else begin

S_AXI_RDATA <= 32'b0;
S_AXI_RRESP <= 2'b10;

end

S_AXI_RVALID <= 1'b1;

end

if(S_AXI_RVALID &&
   S_AXI_RREADY) begin

S_AXI_RVALID <= 1'b0;

end

end

end

endmodule

