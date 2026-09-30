module axi_uart_system #(
parameter CLKS_PER_BIT = 8
)(
input clk,
input reset,

// ==================================================
// Simple Request Interface
// ==================================================

input req_read,
input req_write,

input [31:0] req_address,
input [31:0] req_write_data,

output [31:0] resp_read_data,
output resp_ready,
output resp_error,

// ==================================================
// UART Pins
// ==================================================

output uart_tx_line,
input uart_rx_line
);


// ==================================================
// AXI4-Lite Internal Wires
// ==================================================

// Write address channel

wire [31:0] axi_awaddr;
wire axi_awvalid;
wire axi_awready;


// Write data channel

wire [31:0] axi_wdata;
wire [3:0] axi_wstrb;
wire axi_wvalid;
wire axi_wready;


// Write response channel

wire [1:0] axi_bresp;
wire axi_bvalid;
wire axi_bready;


// Read address channel

wire [31:0] axi_araddr;
wire axi_arvalid;
wire axi_arready;


// Read data channel

wire [31:0] axi_rdata;
wire [1:0] axi_rresp;
wire axi_rvalid;
wire axi_rready;


// ==================================================
// AXI4-Lite Master Bridge
// ==================================================

axi_lite_master_bridge master_bridge(

.clk(clk),
.reset(reset),

.req_read(req_read),
.req_write(req_write),

.req_address(req_address),
.req_write_data(req_write_data),

.resp_read_data(resp_read_data),
.resp_ready(resp_ready),
.resp_error(resp_error),

.M_AXI_AWADDR(axi_awaddr),
.M_AXI_AWVALID(axi_awvalid),
.M_AXI_AWREADY(axi_awready),

.M_AXI_WDATA(axi_wdata),
.M_AXI_WSTRB(axi_wstrb),
.M_AXI_WVALID(axi_wvalid),
.M_AXI_WREADY(axi_wready),

.M_AXI_BRESP(axi_bresp),
.M_AXI_BVALID(axi_bvalid),
.M_AXI_BREADY(axi_bready),

.M_AXI_ARADDR(axi_araddr),
.M_AXI_ARVALID(axi_arvalid),
.M_AXI_ARREADY(axi_arready),

.M_AXI_RDATA(axi_rdata),
.M_AXI_RRESP(axi_rresp),
.M_AXI_RVALID(axi_rvalid),
.M_AXI_RREADY(axi_rready)

);


// ==================================================
// AXI4-Lite UART Slave
// ==================================================

axi_uart_slave #(
.CLKS_PER_BIT(CLKS_PER_BIT)
)
uart_slave(

.clk(clk),
.reset(reset),

.S_AXI_AWADDR(axi_awaddr),
.S_AXI_AWVALID(axi_awvalid),
.S_AXI_AWREADY(axi_awready),

.S_AXI_WDATA(axi_wdata),
.S_AXI_WSTRB(axi_wstrb),
.S_AXI_WVALID(axi_wvalid),
.S_AXI_WREADY(axi_wready),

.S_AXI_BRESP(axi_bresp),
.S_AXI_BVALID(axi_bvalid),
.S_AXI_BREADY(axi_bready),

.S_AXI_ARADDR(axi_araddr),
.S_AXI_ARVALID(axi_arvalid),
.S_AXI_ARREADY(axi_arready),

.S_AXI_RDATA(axi_rdata),
.S_AXI_RRESP(axi_rresp),
.S_AXI_RVALID(axi_rvalid),
.S_AXI_RREADY(axi_rready),

.uart_tx_line(uart_tx_line),
.uart_rx_line(uart_rx_line)

);

endmodule