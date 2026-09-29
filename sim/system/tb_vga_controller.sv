`timescale 1ns/1ps
// Focused VGA timing/address/RGB test.
module tb_vga_controller;
    logic pclk=0, rst_n=0, display_enable=0, duck_enable=0;
    wire [18:0] fb_addr;
    logic [7:0] fb_rdata=8'hA5;
    wire duck_hit; wire [7:0] duck_rgb;
    wire hsync, vsync, active; wire [7:0] rgb;
    wire [11:0] hcount, vcount;
    int errors=0;
    always #20 pclk=~pclk;

    vga_controller dut (
        .pclk(pclk), .rst_n(rst_n), .display_enable(display_enable),
        .fb_addr(fb_addr), .fb_rdata(fb_rdata), .duck_enable(duck_enable),
        .duck_frame(6'd0), .duck_hit(duck_hit), .duck_rgb(duck_rgb),
        .hsync(hsync), .vsync(vsync), .video_active(active), .rgb(rgb),
        .hcount(hcount), .vcount(vcount)
    );

    task automatic check(input bit c, input string s);
        if(c) $display("VGA PASS: %s",s);
        else begin $error("VGA FAIL: %s",s); errors++; end
    endtask

        initial begin
        $dumpfile("sim/output/vga_controller.vcd"); $dumpvars(0, tb_vga_controller);
        repeat(3) @(posedge pclk); rst_n=1; display_enable=1;
        wait(hcount==12'd10 && vcount==12'd0);
        #1;
        check(active, "active video asserted inside 640x480");
        check(fb_addr==19'd11, "next-pixel prefetch address for x=10,y=0");
        wait(hcount==12'd638 && vcount==12'd479);
        #1;
        check(fb_addr==19'd307199, "prefetch points to final framebuffer pixel before line end");
        wait(hcount==12'd639 && vcount==12'd479);
        #1;
        check(active, "last visible pixel active");
        check(fb_addr==19'd0, "prefetch wraps after final visible pixel");
        wait(hcount==12'd656 && vcount==12'd0);
        #1; check(hsync===0, "HSYNC active at 656");
        wait(hcount==12'd752 && vcount==12'd0);
        #1; check(hsync===1, "HSYNC inactive after 96 clocks");
        wait(vcount==12'd490 && hcount==0);
        #1; check(vsync===0, "VSYNC starts at line 490");
        display_enable=0;
        repeat(3) @(posedge pclk); #1;
        check(rgb===8'h00, "RGB black when display disabled");

        if(errors==0) begin
            $display("============================================");
            $display(" VGA CONTROLLER TEST PASSED");
            $display("============================================");
            $finish;
        end else $fatal(1,"VGA errors=%0d",errors);
    end
endmodule
