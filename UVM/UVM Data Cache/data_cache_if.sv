interface data_cache_if(input logic clk);

    logic [3:0]  mem_addr;
    logic        mem_read;
    logic        mem_write;
    logic [31:0] cache_i;
    logic [31:0] cache_o;
    logic [3:0]  write_mask;

endinterface
