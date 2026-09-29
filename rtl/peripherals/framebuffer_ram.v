// Dual-port 8-bit framebuffer RAM.
// Port A: CPU-side byte writes through the native interconnect.
// Port B: VGA-side synchronous pixel reads.
module framebuffer_ram #(
    parameter integer ADDR_WIDTH = 19,
    parameter integer DATA_WIDTH = 8,
    parameter integer DEPTH = (1 << ADDR_WIDTH)
)(
    input wire clk_a,
    input wire [3:0] we_a,
    input wire [ADDR_WIDTH-1:0] addr_a,
    input wire [31:0] din_a,
    output reg [DATA_WIDTH-1:0] dout_a,
    input wire clk_b,
    input wire [ADDR_WIDTH-1:0] addr_b,
    output reg [DATA_WIDTH-1:0] dout_b
);
    reg [DATA_WIDTH-1:0] ram [0:DEPTH-1];
    integer i;

`ifdef SIMULATION
    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            ram[i] = {DATA_WIDTH{1'b0}};
    end
`endif

    // Address is the containing word for writes. The interconnect aligns it,
    // while byte strobes select the individual framebuffer byte lanes.
    always @(posedge clk_a) begin
        if (we_a[0] && (addr_a < DEPTH))     ram[addr_a]     <= din_a[7:0];
        if (we_a[1] && ((addr_a + 1) < DEPTH)) ram[addr_a + 1] <= din_a[15:8];
        if (we_a[2] && ((addr_a + 2) < DEPTH)) ram[addr_a + 2] <= din_a[23:16];
        if (we_a[3] && ((addr_a + 3) < DEPTH)) ram[addr_a + 3] <= din_a[31:24];
        if (addr_a < DEPTH)
            dout_a <= ram[addr_a];
        else
            dout_a <= {DATA_WIDTH{1'b0}};
    end

    always @(posedge clk_b) begin
        if (addr_b < DEPTH)
            dout_b <= ram[addr_b];
        else
            dout_b <= {DATA_WIDTH{1'b0}};
    end
endmodule
