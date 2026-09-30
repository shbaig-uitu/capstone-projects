module mailbox_reg(
input clk,
input reset,

input write_en,
input read_en,
input [31:0] address,
input [31:0] write_data,
output reg [31:0] read_data
);

reg [31:0] message;
reg valid;

always @(posedge clk) begin

if(reset) begin
message <= 32'b0;
valid <= 1'b0;
end

else if(write_en && address == 32'h00001000) begin
message <= write_data;
valid <= 1'b1;
end

else if(read_en && address == 32'h00001000) begin
valid <= 1'b0;
end

end

always @(*) begin

read_data = 32'b0;

if(read_en && address == 32'h00001000)
read_data = message;

else if(read_en && address == 32'h00001004)
read_data = {31'b0,valid};

end

endmodule

