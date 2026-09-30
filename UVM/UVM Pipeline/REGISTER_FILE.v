module registerfile (
    en, rst, clk, rd_addr, data_in, rs1_addr, rs2_addr, op_a, op_b
    );
    input  wire        clk, rst, en;
    input  wire  [4:0] rd_addr, rs1_addr, rs2_addr;
    input  wire [31:0] data_in;
    output wire [31:0] op_a, op_b;

    reg [31:0] rd [31:0];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                rd[i] <= 32'b0;
        end else if (en && (rd_addr != 5'b0)) begin
            rd[rd_addr] <= data_in; // Fix: Value hold rahegi agar en=0 ho
        end
    end

    assign op_a = (|rs1_addr) ? rd[rs1_addr] : 32'b0;
    assign op_b = (|rs2_addr) ? rd[rs2_addr] : 32'b0;
endmodule
