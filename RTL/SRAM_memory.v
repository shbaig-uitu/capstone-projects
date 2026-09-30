`timescale 1ns / 1ps

module sram_memory #(
    parameter ADDR_WIDTH = 8,       // 256 words = 1KB
    parameter DATA_WIDTH = 32
)(
    input  wire                   clk,
    input  wire                   reset,

    // Memory Bus Interface
    input  wire [31:0]            addr,
    input  wire [DATA_WIDTH-1:0]  wdata,
    input  wire [3:0]             wstrb,     // Byte-write enables (4'b1111 for full word)
    input  wire                   mem_read,
    input  wire                   mem_write,
    output wire [DATA_WIDTH-1:0]  rdata
);

    // 256 x 32-bit Memory Array (1024 bytes)
    reg [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH)-1];

    // Word-aligned index extraction (ignore byte offsets addr[1:0])
    wire [ADDR_WIDTH-1:0] word_addr = addr[ADDR_WIDTH+1:2];

    // Synchronous Byte-Gated Write
    integer i;
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            // Optional zero-out on reset for deterministic simulation
            for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (mem_write) begin
            if (wstrb[0]) mem[word_addr][7:0]   <= wdata[7:0];
            if (wstrb[1]) mem[word_addr][15:8]  <= wdata[15:8];
            if (wstrb[2]) mem[word_addr][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[word_addr][31:24] <= wdata[31:24];
        end
    end

    // Combinational Read Path (Single-Cycle Core Compatibility)
    assign rdata = (mem_read) ? mem[word_addr] : {DATA_WIDTH{1'b0}};

endmodule
