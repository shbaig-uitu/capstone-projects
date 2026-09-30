interface shared_mem_if(input logic clk);
    logic [3:0]  addr0, addr1;
    logic        read0, write0, read1, write1;
    logic [31:0] wdata0, wdata1;
    logic [3:0]  wmask0, wmask1;
    logic [31:0] rdata0, rdata1;
endinterface
