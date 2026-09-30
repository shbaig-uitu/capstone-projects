module noc_interconnect(
input clk,
input reset,

// ==================================================
// CORE 0
// ==================================================

input core0_read,
input core0_write,
input [31:0] core0_address,
input [31:0] core0_write_data,
output reg [31:0] core0_read_data,
output reg core0_ready,

// ==================================================
// CORE 1
// ==================================================

input core1_read,
input core1_write,
input [31:0] core1_address,
input [31:0] core1_write_data,
output reg [31:0] core1_read_data,
output reg core1_ready,

// ==================================================
// SHARED SRAM
// ==================================================

output reg mem_read,
output reg mem_write,
output reg [31:0] mem_address,
output reg [31:0] mem_write_data,
input [31:0] mem_read_data,

// ==================================================
// MAILBOX
// ==================================================

output reg mailbox_read,
output reg mailbox_write,
output reg [31:0] mailbox_address,
output reg [31:0] mailbox_write_data,
input [31:0] mailbox_read_data,

// ==================================================
// UART / AXI
// ==================================================

output reg uart_read,
output reg uart_write,
output reg [31:0] uart_address,
output reg [31:0] uart_write_data,

input [31:0] uart_read_data,
input uart_ready,
input uart_error
);


// ==================================================
// REQUESTS
// ==================================================

wire core0_request;
wire core1_request;

assign core0_request = core0_read | core0_write;
assign core1_request = core1_read | core1_write;


// ==================================================
// ARBITRATION STATE
// ==================================================

reg last_grant;
reg grant_core;


// ==================================================
// UART TRANSACTION LOCK
// ==================================================

reg uart_lock;
reg uart_owner;


// ==================================================
// ADDRESS DECODING FUNCTIONS
// ==================================================

function is_sram_address;
input [31:0] address;
begin

if(address <= 32'h00000FFF)
    is_sram_address = 1'b1;
else
    is_sram_address = 1'b0;

end
endfunction


function is_mailbox_address;
input [31:0] address;
begin

if((address == 32'h00001000) ||
   (address == 32'h00001004))

    is_mailbox_address = 1'b1;

else
    is_mailbox_address = 1'b0;

end
endfunction


function is_uart_address;
input [31:0] address;
begin

if((address == 32'h00002000) ||
   (address == 32'h00002004) ||
   (address == 32'h00002008))

    is_uart_address = 1'b1;

else
    is_uart_address = 1'b0;

end
endfunction


// ==================================================
// COMBINATIONAL ROUTING
// ==================================================

always @(*) begin

// --------------------------------------------------
// Defaults
// --------------------------------------------------

core0_read_data = 32'b0;
core1_read_data = 32'b0;

core0_ready = 1'b0;
core1_ready = 1'b0;


// SRAM

mem_read = 1'b0;
mem_write = 1'b0;
mem_address = 32'b0;
mem_write_data = 32'b0;


// Mailbox

mailbox_read = 1'b0;
mailbox_write = 1'b0;
mailbox_address = 32'b0;
mailbox_write_data = 32'b0;


// UART

uart_read = 1'b0;
uart_write = 1'b0;
uart_address = 32'b0;
uart_write_data = 32'b0;


grant_core = 1'b0;


// ==================================================
// SELECT OWNER
// ==================================================

// IMPORTANT:
//
// Once an AXI/UART transaction starts,
// keep the same core selected until uart_ready.

if(uart_lock) begin

    grant_core = uart_owner;

end

else begin

    // Only Core 0 requesting

    if(core0_request && !core1_request)

        grant_core = 1'b0;


    // Only Core 1 requesting

    else if(!core0_request && core1_request)

        grant_core = 1'b1;


    // Both request

    else if(core0_request && core1_request) begin

        if(last_grant == 1'b0)
            grant_core = 1'b1;
        else
            grant_core = 1'b0;

    end

end


// ==================================================
// ROUTE REQUEST
// ==================================================

if(core0_request || core1_request || uart_lock) begin


// ==================================================
// CORE 0 SELECTED
// ==================================================

if(grant_core == 1'b0) begin


// --------------------------------------------------
// SRAM
// --------------------------------------------------

if(is_sram_address(core0_address)) begin

    mem_read = core0_read;
    mem_write = core0_write;

    mem_address = core0_address;
    mem_write_data = core0_write_data;

    core0_read_data = mem_read_data;
    core0_ready = 1'b1;

end


// --------------------------------------------------
// MAILBOX
// --------------------------------------------------

else if(is_mailbox_address(core0_address)) begin

    mailbox_read = core0_read;
    mailbox_write = core0_write;

    mailbox_address = core0_address;
    mailbox_write_data = core0_write_data;

    core0_read_data = mailbox_read_data;
    core0_ready = 1'b1;

end


// --------------------------------------------------
// UART
// --------------------------------------------------

else if(is_uart_address(core0_address)) begin

    uart_read = core0_read;
    uart_write = core0_write;

    uart_address = core0_address;
    uart_write_data = core0_write_data;

    core0_read_data = uart_read_data;

    // Core completes only when AXI completes
    core0_ready = uart_ready;

end


// --------------------------------------------------
// INVALID
// --------------------------------------------------

else begin

    core0_read_data = 32'b0;
    core0_ready = 1'b1;

end

end


// ==================================================
// CORE 1 SELECTED
// ==================================================

else begin


// --------------------------------------------------
// SRAM
// --------------------------------------------------

if(is_sram_address(core1_address)) begin

    mem_read = core1_read;
    mem_write = core1_write;

    mem_address = core1_address;
    mem_write_data = core1_write_data;

    core1_read_data = mem_read_data;
    core1_ready = 1'b1;

end


// --------------------------------------------------
// MAILBOX
// --------------------------------------------------

else if(is_mailbox_address(core1_address)) begin

    mailbox_read = core1_read;
    mailbox_write = core1_write;

    mailbox_address = core1_address;
    mailbox_write_data = core1_write_data;

    core1_read_data = mailbox_read_data;
    core1_ready = 1'b1;

end


// --------------------------------------------------
// UART
// --------------------------------------------------

else if(is_uart_address(core1_address)) begin

    uart_read = core1_read;
    uart_write = core1_write;

    uart_address = core1_address;
    uart_write_data = core1_write_data;

    core1_read_data = uart_read_data;

    core1_ready = uart_ready;

end


// --------------------------------------------------
// INVALID
// --------------------------------------------------

else begin

    core1_read_data = 32'b0;
    core1_ready = 1'b1;

end

end

end

end


// ==================================================
// SEQUENTIAL ARBITRATION / UART LOCK
// ==================================================

always @(posedge clk) begin

if(reset) begin

    last_grant <= 1'b0;

    uart_lock <= 1'b0;
    uart_owner <= 1'b0;

end

else begin


// ==================================================
// UART LOCK CONTROL
// ==================================================

if(uart_lock) begin

    // AXI transaction finished

    if(uart_ready)

        uart_lock <= 1'b0;

end

else begin

    // Start UART transaction from Core 0

    if(
       grant_core == 1'b0 &&
       core0_request &&
       is_uart_address(core0_address)
      ) begin

        uart_lock <= 1'b1;
        uart_owner <= 1'b0;

    end


    // Start UART transaction from Core 1

    else if(
       grant_core == 1'b1 &&
       core1_request &&
       is_uart_address(core1_address)
      ) begin

        uart_lock <= 1'b1;
        uart_owner <= 1'b1;

    end

end


// ==================================================
// ROUND ROBIN HISTORY
//
// Don't change owner while UART transaction
// is locked.
// ==================================================

if(!uart_lock &&
   core0_request &&
   core1_request)

    last_grant <= grant_core;

end

end

endmodule