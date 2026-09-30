module registerfile (
    en,
    rst,
    clk,
    rd_addr,
    data_in,
    rs1_addr,
    rs2_addr,
    op_a,
    op_b
    );
    input  wire        clk;
    input  wire        rst;
    input  wire        en;
    input  wire  [4:0] rd_addr;
    input  wire [31:0] data_in;
    input  wire  [4:0] rs1_addr;
    input  wire  [4:0] rs2_addr;
    output wire [31:0] op_a;
    output wire [31:0] op_b;

    reg [31:0] rd [31:0];
    integer i;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 32; i = i + 1)
                rd[i] <= 32'b0;
        end
        else begin
            rd[rd_addr] <= (en) ? data_in : 0;
        end
    end

    assign op_a = (|rs1_addr) ? rd[rs1_addr] : 0;
    assign op_b = (|rs2_addr) ? rd[rs2_addr] : 0;
endmodule
