module shared_mem (
    clk,
    addr0, read0, write0, wdata0, wmask0, rdata0,
    addr1, read1, write1, wdata1, wmask1, rdata1
);
    input  wire        clk;
    input  wire [3:0]  addr0, addr1;
    input  wire        read0, write0, read1, write1;
    input  wire [31:0] wdata0, wdata1;
    input  wire [3:0]  wmask0, wmask1;
    output reg  [31:0] rdata0, rdata1;

    reg [31:0] mem [0:15];

    // two fully independent combinational read ports -- no conflict possible
    always @(*) begin
        rdata0 = mem[addr0];
        rdata1 = mem[addr1];
    end

    wire collision = write0 && write1 && (addr0 == addr1);
    // core0 wins a same-address, same-cycle write collision; core1's write is dropped that cycle

    always @(posedge clk) begin
        if (write0) begin
            if (wmask0[0]) mem[addr0][7:0]   <= wdata0[7:0];
            if (wmask0[1]) mem[addr0][15:8]  <= wdata0[15:8];
            if (wmask0[2]) mem[addr0][23:16] <= wdata0[23:16];
            if (wmask0[3]) mem[addr0][31:24] <= wdata0[31:24];
        end
        if (write1 && !collision) begin
            if (wmask1[0]) mem[addr1][7:0]   <= wdata1[7:0];
            if (wmask1[1]) mem[addr1][15:8]  <= wdata1[15:8];
            if (wmask1[2]) mem[addr1][23:16] <= wdata1[23:16];
            if (wmask1[3]) mem[addr1][31:24] <= wdata1[31:24];
        end
    end
endmodule