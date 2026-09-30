module mailbox_system(
input clk,
input reset,

// ==================================================
// CORE 0
// ==================================================

input core0_read,
input core0_write,
input [31:0] core0_address,
input [31:0] core0_write_data,
output [31:0] core0_read_data,
output core0_ready,

// ==================================================
// CORE 1
// ==================================================

input core1_read,
input core1_write,
input [31:0] core1_address,
input [31:0] core1_write_data,
output [31:0] core1_read_data,
output core1_ready,

// ==================================================
// UART EXTERNAL PINS
// ==================================================

output uart_tx_line,
input uart_rx_line
);


// ==================================================
// SHARED SRAM WIRES
// ==================================================

wire mem_read;
wire mem_write;

wire [31:0] mem_address;
wire [31:0] mem_write_data;
wire [31:0] mem_read_data;


// ==================================================
// MAILBOX WIRES
// ==================================================

wire mailbox_read;
wire mailbox_write;

wire [31:0] mailbox_address;
wire [31:0] mailbox_write_data;
wire [31:0] mailbox_read_data;


// ==================================================
// UART REQUEST WIRES
// ==================================================

wire uart_read;
wire uart_write;

wire [31:0] uart_address;
wire [31:0] uart_write_data;

wire [31:0] uart_read_data;
wire uart_ready;
wire uart_error;


// ==================================================
// INTERCONNECT
// ==================================================

noc_interconnect interconnect_unit(

.clk(clk),
.reset(reset),

// Core 0

.core0_read(core0_read),
.core0_write(core0_write),
.core0_address(core0_address),
.core0_write_data(core0_write_data),
.core0_read_data(core0_read_data),
.core0_ready(core0_ready),

// Core 1

.core1_read(core1_read),
.core1_write(core1_write),
.core1_address(core1_address),
.core1_write_data(core1_write_data),
.core1_read_data(core1_read_data),
.core1_ready(core1_ready),

// SRAM

.mem_read(mem_read),
.mem_write(mem_write),
.mem_address(mem_address),
.mem_write_data(mem_write_data),
.mem_read_data(mem_read_data),

// Mailbox

.mailbox_read(mailbox_read),
.mailbox_write(mailbox_write),
.mailbox_address(mailbox_address),
.mailbox_write_data(mailbox_write_data),
.mailbox_read_data(mailbox_read_data),

// UART

.uart_read(uart_read),
.uart_write(uart_write),
.uart_address(uart_address),
.uart_write_data(uart_write_data),
.uart_read_data(uart_read_data),
.uart_ready(uart_ready),
.uart_error(uart_error)

);


// ==================================================
// SHARED SRAM
// ==================================================

shared_data_memory shared_memory(

.clk(clk),
.reset(reset),

.mem_read(mem_read),
.mem_write(mem_write),

.address(mem_address),
.write_data(mem_write_data),

.read_data(mem_read_data)

);


// ==================================================
// MAILBOX
// ==================================================

mailbox_reg mailbox_unit(

.clk(clk),
.reset(reset),

.write_en(mailbox_write),
.read_en(mailbox_read),

.address(mailbox_address),
.write_data(mailbox_write_data),

.read_data(mailbox_read_data)

);


// ==================================================
// AXI4-LITE UART PERIPHERAL SYSTEM
// ==================================================

axi_uart_system #(
.CLKS_PER_BIT(8)
)
uart_system(

.clk(clk),
.reset(reset),

.req_read(uart_read),
.req_write(uart_write),

.req_address(uart_address),
.req_write_data(uart_write_data),

.resp_read_data(uart_read_data),
.resp_ready(uart_ready),
.resp_error(uart_error),

.uart_tx_line(uart_tx_line),
.uart_rx_line(uart_rx_line)

);

endmodule