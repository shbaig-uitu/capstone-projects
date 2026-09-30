// RISC-V Register File: 32 x 32-bit registers
// 2 asynchronous read ports, 1 synchronous write port
// x0 (index 0) always reads as zero; writes to x0 are ignored
module regfile (
    input  wire        clk,
    input  wire        we,          // write enable
    input  wire [4:0]  waddr,       // write address (rd)
    input  wire [31:0] wdata,       // write data
    input  wire [4:0]  raddr1,      // read address 1 (rs1)
    output wire [31:0] rdata1,      // read data 1
    input  wire [4:0]  raddr2,      // read address 2 (rs2)
    output wire [31:0] rdata2,      // read data 2
    output wire [31:0] x7_out,      // read port for x7
    output wire [31:0] x8_out       // read port for x8
);
    reg [31:0] regs [0:31];
    integer i;
    initial begin
        for(i=0; i<32; i=i+1) regs[i] = 32'b0;
        // Set Stack Pointer (x2) to the top of the 1KB Data Memory
        regs[2] = 32'h000003FC; 
    end

    // synchronous write - x0 stays zero (waddr==0 is ignored)
    always @(posedge clk)
        if (we && waddr != 5'd0) regs[waddr] <= wdata;

    // asynchronous reads - x0 always returns 0
    assign rdata1 = (raddr1 == 5'd0) ? 32'd0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'd0) ? 32'd0 : regs[raddr2];
    assign x7_out = regs[7];
    assign x8_out = regs[8];
endmodule
