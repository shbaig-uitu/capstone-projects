module reg_file(
    input  wire        clk,
    input  wire        reset,
    input  wire        reg_write_en,
    input  wire        stall,        
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] rd_write_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    reg [31:0] registers [0:31];
    integer i;
        
    assign rs1_data = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
    assign rs2_data = (rs2 == 5'b0) ? 32'b0 : registers[rs2];

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i <= 31; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else begin
            if (reg_write_en && (rd != 5'b0) && !stall) begin
                registers[rd] <= rd_write_data;
            end
        end
    end

endmodule
