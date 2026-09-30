
module soc_top_tb;

    reg         clk;
    reg         rst;
    reg         instruct_en0;
    reg         instruct_en1;
    wire [31:0] result0;
    wire [31:0] result1;

    soc_top uut (
        .rst         (rst),
        .clk         (clk),
        .instruct_en0(instruct_en0),
        .instruct_en1(instruct_en1),
        .result0     (result0),
        .result1     (result1)
    );

    // clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst          = 0;   // active-low, per program_counter
        instruct_en0 = 1;
        instruct_en1 = 1;


        #12 rst = 1;   // release reset after a couple clock edges

        #100;
        $display("core0 result = %0d (0x%08h)", result0, result0);
        $display("core1 result = %0d (0x%08h)", result1, result1);
        $finish;
    end

    // flag every write collision as it happens, showing core0 winning
    always @(posedge clk) begin
        if (uut.shared_write0 && uut.shared_write1 &&
            (uut.shared_addr0 == uut.shared_addr1)) begin
            $display("[%0t] COLLISION addr=%0d : core0 wdata=%0h WINS, core1 wdata=%0h dropped",
                       $time, uut.shared_addr0, uut.shared_wdata0, uut.shared_wdata1);
        end
    end

    // full per-cycle trace of both cores' shared-mem traffic
    always @(posedge clk) begin
        $display("[%0t] core0: addr=%0d r=%0b w=%0b wdata=%0h rdata=%0h | core1: addr=%0d r=%0b w=%0b wdata=%0h rdata=%0h",
                   $time,
                   uut.shared_addr0, uut.shared_read0, uut.shared_write0, uut.shared_wdata0, uut.shared_rdata0,
                   uut.shared_addr1, uut.shared_read1, uut.shared_write1, uut.shared_wdata1, uut.shared_rdata1);
    end

endmodule
