module baud_gen(
    input clk,
    input reset,
    input enable,
    input half,
    output tick
);

parameter CLKS_PER_BIT = 8;

reg [15:0] count;
wire [15:0] target = half ? (CLKS_PER_BIT/2 - 1) : (CLKS_PER_BIT - 1);

assign tick = enable && (count == target);

always @(posedge clk) begin
    if (reset || !enable)
        count <= 0;
    else if (count == target)
        count <= 0;
    else
        count <= count + 1'b1;
end

endmodule
