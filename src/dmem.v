// dmem.v (Shrunk for ASIC Physical Design)
// Shrunk to 16 words (64 bytes) to prevent ABC optimizer hang
module dmem #(parameter DEPTH = 16) (
    input         clk,
    input         we,
    input  [31:0] addr,
    input  [31:0] wdata,
    input  [ 2:0] funct3,
    output reg [31:0] rdata
);
    reg [7:0] mem [0:(DEPTH*4)-1];

    always @(posedge clk) begin
        if (we) begin
            case (funct3)
                3'b000: begin mem[addr] <= wdata[7:0]; end
                3'b001: begin mem[addr] <= wdata[7:0]; mem[addr+1] <= wdata[15:8]; end
                3'b010: begin 
                    mem[addr]   <= wdata[7:0];   mem[addr+1] <= wdata[15:8];
                    mem[addr+2] <= wdata[23:16]; mem[addr+3] <= wdata[31:24];
                end
                default: ; 
            endcase
        end
    end

    // Mask the address to prevent out-of-bounds simulation errors
    wire [31:0] safe_addr = addr & 32'h0000_003F; 

    always @(*) begin
        case (funct3)
            3'b000: rdata = {{24{mem[safe_addr][7]}}, mem[safe_addr]};
            3'b001: rdata = {{16{mem[safe_addr+1][7]}}, mem[safe_addr+1], mem[safe_addr]};
            3'b010: rdata = {mem[safe_addr+3], mem[safe_addr+2], mem[safe_addr+1], mem[safe_addr]};
            3'b100: rdata = {24'b0, mem[safe_addr]};
            3'b101: rdata = {16'b0, mem[safe_addr+1], mem[safe_addr]};
            default: rdata = 32'b0;
        endcase
    end
endmodule
