`timescale 1ns / 1ps

module sram_memory #(
    parameter ADDR_WIDTH = 2,       
    parameter DATA_WIDTH = 32
)(
    input  wire                   clk,
    input  wire                   reset,

    // Memory Bus Interface
    input  wire [31:0]            addr,
    input  wire [DATA_WIDTH-1:0]  wdata,
    input  wire [3:0]             wstrb,
    input  wire                   mem_read,
    input  wire                   mem_write,
    output wire [DATA_WIDTH-1:0]  rdata
);

    // Sirf 4 x 32-bit registers 
    reg [DATA_WIDTH-1:0] mem [0:3];
    wire [1:0] word_addr = addr[3:2];

    // Synchronous Write 
    always @(posedge clk) begin
        if (mem_write) begin
            if (wstrb[0]) mem[word_addr][7:0]   <= wdata[7:0];
            if (wstrb[1]) mem[word_addr][15:8]  <= wdata[15:8];
            if (wstrb[2]) mem[word_addr][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[word_addr][31:24] <= wdata[31:24];
        end
    end

    assign rdata = (mem_read) ? mem[word_addr] : {DATA_WIDTH{1'b0}};

endmodule
