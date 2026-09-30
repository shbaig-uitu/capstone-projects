module shared_data_memory(
input clk,
input reset,
input mem_read,
input mem_write,
input [31:0] address,
input [31:0] write_data,
output [31:0] read_data
);

reg [31:0] memory [0:255];
integer i;

assign read_data = mem_read ? memory[address[9:2]] : 32'b0;

always @(posedge clk) begin
if(reset) begin
for(i=0;i<256;i=i+1)
memory[i] <= 32'b0;
end
else if(mem_write) begin
memory[address[9:2]] <= write_data;
end
end

endmodule
