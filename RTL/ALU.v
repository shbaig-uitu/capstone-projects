module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_control,
    output reg  [31:0] alu_result,
    output wire        zero
);

    assign zero = (alu_result == 32'b0);

    always @(*) begin
        case (alu_control)
            4'b0000: alu_result = a + b;                                  // ADD
            4'b0001: alu_result = a - b;                                  // SUB
            4'b0010: alu_result = a << b[4:0];                            // SLL
            4'b0011: alu_result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            4'b0100: alu_result = (a < b) ? 32'd1 : 32'd0;                // SLTU
            4'b0101: alu_result = a ^ b;                                  // XOR
            4'b0110: alu_result = a >> b[4:0];                            // SRL
            4'b0111: alu_result = $signed(a) >>> b[4:0];                  // SRA
            4'b1000: alu_result = a | b;                                  // OR
            4'b1001: alu_result = a & b;                                  // AND
            default: alu_result = 32'b0;
        endcase
    end

endmodule
