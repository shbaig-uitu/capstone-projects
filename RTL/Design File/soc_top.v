
module soc_top (
    rst,
    clk,
    instruct_en0,
    instruct_en1,
    result0,
    result1
);
    input  wire        rst;
    input  wire        clk;
    input  wire        instruct_en0;
    input  wire        instruct_en1;
    output wire [31:0] result0;
    output wire [31:0] result1;

    // core0 <-> shared_mem port 0
    wire [3:0]  shared_addr0;
    wire        shared_read0;
    wire        shared_write0;
    wire [31:0] shared_wdata0;
    wire [3:0]  shared_wmask0;
    wire [31:0] shared_rdata0;

    // core1 <-> shared_mem port 1
    wire [3:0]  shared_addr1;
    wire        shared_read1;
    wire        shared_write1;
    wire [31:0] shared_wdata1;
    wire [3:0]  shared_wmask1;
    wire [31:0] shared_rdata1;

    topmodule core0 (
        .result      (      result0),
        .rst         (          rst),
        .clk         (          clk),
        .instruct_en (instruct_en0),
        .shared_addr (shared_addr0),
        .shared_read (shared_read0),
        .shared_write(shared_write0),
        .shared_wdata(shared_wdata0),
        .shared_wmask(shared_wmask0),
        .shared_rdata(shared_rdata0)
    );

    topmodule core1 (
        .result      (      result1),
        .rst         (          rst),
        .clk         (          clk),
        .instruct_en (instruct_en1),
        .shared_addr (shared_addr1),
        .shared_read (shared_read1),
        .shared_write(shared_write1),
        .shared_wdata(shared_wdata1),
        .shared_wmask(shared_wmask1),
        .shared_rdata(shared_rdata1)
    );

    shared_mem u_shared_mem (
        .clk   (clk),
        .addr0 (shared_addr0),
        .read0 (shared_read0),
        .write0(shared_write0),
        .wdata0(shared_wdata0),
        .wmask0(shared_wmask0),
        .rdata0(shared_rdata0),
        .addr1 (shared_addr1),
        .read1 (shared_read1),
        .write1(shared_write1),
        .wdata1(shared_wdata1),
        .wmask1(shared_wmask1),
        .rdata1(shared_rdata1)
    );

endmodule