`timescale 1ns/1ps
module tb_riscv_vga_soc;
    logic clk50=0, clk25=0, rst_n=0;
    wire hsync, vsync;
    wire [7:0] rgb;
    wire [3:0] leds;
    integer errors = 0;

    riscv_vga_soc dut (
        .clk_50mhz(clk50), .clk_25mhz(clk25), .rst_n(rst_n),
        .vga_hsync(hsync), .vga_vsync(vsync), .vga_rgb(rgb), .debug_leds(leds)
    );

    always #10 clk50 = ~clk50;
    always #20 clk25 = ~clk25;

    task automatic check(input integer cond, input [255:0] msg);
        begin
            if(cond) $display("SOC PASS: %s", msg);
            else begin $display("SOC FAIL: %s", msg); errors = errors + 1; end
        end
    endtask

        initial begin
        $dumpfile("sim/output/riscv_vga_soc.vcd");
        $dumpvars(1, tb_riscv_vga_soc);
        $dumpvars(0, dut.cpu); $dumpvars(0, dut.vga); $dumpvars(0, dut.regs);
        $display("============================================");
        $display(" PROJECT 02: RV32I + VGA SoC TEST");
        $display("============================================");
        repeat(10) @(posedge clk50);
        rst_n = 1'b1;

        fork
            begin
                wait(dut.regs.display_enable === 1'b1);
            end
            begin
                #25_000_000;
                $display("SOC FAIL: timeout waiting for firmware to enable VGA");
                errors = errors + 1;
            end
        join_any
        disable fork;

        check(dut.regs.display_enable === 1'b1, "CPU enabled display via AXI-Lite");
        check(dut.regs.animation_enable === 1'b1, "CPU enabled animation");
        check(dut.fb.ram[0] === 8'h9F, "framebuffer first pixel initialized");
        check(dut.fb.ram[639] === 8'h9F, "framebuffer end-of-line initialized");
        check(dut.fb.ram[307199] === 8'h9F, "framebuffer last pixel initialized");
        check(dut.fb_base === 32'h0001_0000, "default framebuffer base");
        check(dut.cpu.trap === 1'b0, "CPU trap remains clear");

        repeat(20) @(posedge clk25);
        check(dut.vga.video_active === 1'b1, "VGA active-video region reached");
        check(dut.vga.hcount < 640 && dut.vga.vcount < 480, "visible coordinates valid");

        wait(dut.vga.hcount == 12'd70 && dut.vga.vcount == 12'd237);
        #1 check(dut.vga.duck_hit === 1'b1, "duck overlay is detected in visible area");

        wait(dut.vga.hcount == 12'd656 && dut.vga.vcount == 12'd0);
        #1 check(hsync === 1'b0, "HSYNC asserted for sync interval");
        wait(dut.vga.hcount == 12'd752 && dut.vga.vcount == 12'd0);
        #1 check(hsync === 1'b1, "HSYNC deasserted after 96 pixels");

        wait(dut.vga.hcount == 12'd0 && dut.vga.vcount == 12'd490);
        #1 check(vsync === 1'b0, "VSYNC asserted at line 490");
        wait(dut.vga.hcount == 12'd0 && dut.vga.vcount == 12'd492);
        #1 check(vsync === 1'b1, "VSYNC deasserted after 2 lines");

        force dut.regs.display_enable = 1'b0;
        repeat(4) @(posedge clk25);
        #1 check(rgb === 8'h00, "RGB is black while display disabled");
        release dut.regs.display_enable;

        if(errors == 0) begin
            $display("============================================");
            $display(" ALL RV32I/VGA SOC TESTS PASSED");
            $display("============================================");
            $finish;
        end else begin
            $fatal(1, "SOC test failed with %0d error(s)", errors);
        end
    end
endmodule
