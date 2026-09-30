module program_counter(
    input  wire        clk,
    input  wire        reset,
    input  wire        stall,      
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        pc <= 32'b0;
    end else if (!stall) begin          
        pc <= next_pc;
    end
end

endmodule
