module data_cache (
    clk,
    mem_addr,
    mem_read,
    mem_write,
    cache_i,
    cache_o,
    write_mask,
    shared_addr,
    shared_read,
    shared_write,
    shared_wdata,
    shared_wmask,
    shared_rdata
);
    input  wire        clk;
    input  wire [3:0]  mem_addr;
    input  wire        mem_read;
    input  wire        mem_write;
    input  wire [31:0] cache_i;
    output reg  [31:0] cache_o;
    input  wire [3:0]  write_mask;

    output reg  [3:0]  shared_addr;
    output reg          shared_read;
    output reg          shared_write;
    output reg  [31:0] shared_wdata;
    output reg  [3:0]  shared_wmask;
    input  wire [31:0] shared_rdata;

    reg [31:0] cache_data [0:15];

    wire hit = mem_read && (cache_data[mem_addr] != 32'b0);

    always @(*) begin
        shared_addr  = mem_addr;
        shared_wdata = cache_i;
        shared_wmask = write_mask;
        shared_write = mem_write;
        shared_read  = mem_read && !hit;
        cache_o      = mem_write ? 32'b0
                      : hit       ? cache_data[mem_addr]
                                  : shared_rdata;
    end

    always @(posedge clk) begin
        if (mem_write)
            cache_data[mem_addr] <= cache_i;
        else if (mem_read && !hit)
            cache_data[mem_addr] <= shared_rdata;
    end

endmodule
