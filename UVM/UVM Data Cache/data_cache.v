module data_cache (
    clk,
    mem_addr,
    mem_read,
    mem_write,
    cache_i,
    cache_o,
    write_mask
);

    input  wire        clk;
    input  wire [3:0]  mem_addr;
    input  wire        mem_read;
    input  wire        mem_write;
    input  wire [31:0] cache_i;
    output reg  [31:0] cache_o;
    input  wire [3:0]  write_mask;

    reg [31:0] cache_data [0:15];

    wire hit = mem_read && (cache_data[mem_addr] != 32'b0);

    always @(*) begin

        if (mem_write)
            cache_o = 32'b0;

        else if (mem_read && hit)
            cache_o = cache_data[mem_addr];

        else
            cache_o = 32'b0;   // MISS

    end

    always @(posedge clk) begin

        if (mem_write)
            cache_data[mem_addr] <= cache_i;

    end

endmodule
