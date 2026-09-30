

module tb_processing_element;

    logic clk, rst;
    logic signed [7:0] a_in, b_in;
    logic signed [31:0] acc_out;

    processing_element PE (
        .clk(clk),
        .rst(rst),
        .a_in(a_in),
        .b_in(b_in),
        .acc_out(acc_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        a_in = 0;
        b_in = 0;

        #10 rst = 0;

        a_in = 2; b_in = 3;   // 2×3 = 6
        #10;

        a_in = 4; b_in = 5;   // 4×5 = 20 ? total 26
        #10;

        a_in = 3; b_in = 2;   // 3×2 = 6 ? total 32
        #10;

        $finish;
    end

endmodule