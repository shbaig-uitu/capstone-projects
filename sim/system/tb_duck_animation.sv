`timescale 1ns/1ps
// Small-period unit test for the animation controller.
// The full SoC uses 5,000,000 ticks at 50 MHz = 100 ms = 10 FPS.
module tb_duck_animation;
    logic clk=0, rst_n=0, enable=0;
    wire [5:0] frame_index;
    int errors=0;
    always #5 clk=~clk;

    duck_animation #(.FRAME_TICKS(5)) dut (
        .clk(clk), .rst_n(rst_n), .enable(enable), .frame_index(frame_index)
    );

    task automatic check(input bit c,input string s);
        if(c) $display("ANIM PASS: %s",s);
        else begin $error("ANIM FAIL: %s",s); errors++; end
    endtask

        initial begin
        $dumpfile("sim/output/duck_animation.vcd"); $dumpvars(0, tb_duck_animation);
        repeat(2) @(posedge clk); rst_n=1; enable=1;
        repeat(5) @(posedge clk);
        check(frame_index===6'd1,"frame advances after 5 system clocks");
        repeat(5*48) @(posedge clk);
        check(frame_index===6'd49,"frame reaches 49");
        repeat(5) @(posedge clk);
        check(frame_index===6'd0,"frame wraps 49 to 0");
        enable=0; repeat(2) @(posedge clk);
        check(frame_index===6'd0,"disable resets animation frame");
        if(errors==0) $display("ANIMATION TEST PASSED"); else $fatal(1);
        $finish;
    end
endmodule
