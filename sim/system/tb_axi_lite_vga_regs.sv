`timescale 1ns/1ps
// Directed, self-checking AXI4-Lite register test.
module tb_axi_lite_vga_regs;
    logic clk = 0, rst_n = 0;
    logic [31:0] awaddr, wdata, araddr;
    logic awvalid, wvalid, arvalid;
    logic [3:0] wstrb;
    wire awready, wready, arready;
    wire [1:0] bresp, rresp;
    wire bvalid, rvalid;
    logic bready = 0, rready = 0;
    wire [31:0] rdata;
    wire display_enable, animation_enable;
    wire [31:0] fb_base;
    logic [5:0] animation_frame = 0;
    logic video_active = 0;
    logic [11:0] hcount = 0, vcount = 0;
    int errors = 0;

    always #10 clk = ~clk;

    axi_lite_vga_regs dut (
        .clk(clk), .rst_n(rst_n),
        .s_axi_awaddr(awaddr), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
        .s_axi_wdata(wdata), .s_axi_wstrb(wstrb), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
        .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
        .s_axi_araddr(araddr), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
        .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready),
        .display_enable(display_enable), .fb_base(fb_base), .animation_enable(animation_enable),
        .animation_frame(animation_frame), .video_active(video_active),
        .hcount(hcount), .vcount(vcount)
    );

    task automatic check(input bit c, input string s);
        if (c) $display("AXI PASS: %s", s);
        else begin $error("AXI FAIL: %s", s); errors++; end
    endtask

    task automatic axi_write(input [31:0] a, input [31:0] d, input [3:0] st);
        begin
            @(posedge clk);
            awaddr <= a; awvalid <= 1;
            wdata <= d; wstrb <= st; wvalid <= 1;
            while (!awready || !wready) @(posedge clk);
            @(posedge clk);
            awvalid <= 0; wvalid <= 0;
            bready <= 1;
            while (!bvalid) @(posedge clk);
            @(posedge clk);
            bready <= 0;
        end
    endtask

    task automatic axi_read(input [31:0] a, output [31:0] d, output [1:0] r);
        begin
            @(posedge clk);
            araddr <= a; arvalid <= 1;
            while (!arready) @(posedge clk);
            @(posedge clk);
            arvalid <= 0; rready <= 1;
            while (!rvalid) @(posedge clk);
            d = rdata; r = rresp;
            @(posedge clk);
            rready <= 0;
        end
    endtask

    reg [31:0] rd;
    reg [1:0] rr;

        initial begin
        $dumpfile("sim/output/axi_lite_vga_regs.vcd"); $dumpvars(0, tb_axi_lite_vga_regs);
        awaddr=0; wdata=0; araddr=0; awvalid=0; wvalid=0; arvalid=0; wstrb=0;
        repeat(4) @(posedge clk);
        rst_n=1;

        check(display_enable===0 && animation_enable===0, "reset clears control bits");
        check(fb_base===32'h0001_0000, "reset framebuffer base");

        axi_write(32'h1000_0000, 32'h0000_0003, 4'h1);
        check(display_enable===1 && animation_enable===1, "CTRL enables display + animation");
        axi_read(32'h1000_0000, rd, rr);
        check(rr===2'b00 && rd===32'h0000_0003, "CTRL readback");

        axi_write(32'h1000_0010, 32'h0002_0000, 4'hF);
        axi_read(32'h1000_0010, rd, rr);
        check(rr===2'b00 && rd===32'h0002_0000, "FB_BASE write/read");
        axi_write(32'h1000_0010, 32'h0002_0002, 4'hF);
        check(bresp===2'b10, "unaligned FB_BASE configuration returns SLVERR");
        axi_read(32'h1000_0010, rd, rr);
        check(rr===2'b00 && rd===32'h0002_0000, "invalid FB_BASE does not change register");

        hcount = 12'd123; vcount = 12'd456; video_active = 1;
        axi_read(32'h1000_0008, rd, rr);
        check(rr===2'b00 && rd===640, "WIDTH register");
        axi_read(32'h1000_000C, rd, rr);
        check(rr===2'b00 && rd===480, "HEIGHT register");
        axi_read(32'h1000_0014, rd, rr);
        check(rr===2'b00 && rd===123, "HCOUNT status");
        axi_read(32'h1000_0018, rd, rr);
        check(rr===2'b00 && rd===456, "VCOUNT status");

        axi_read(32'h1000_007C, rd, rr);
        check(rr===2'b10, "invalid register read returns SLVERR");
        axi_write(32'h1000_007C, 32'h12345678, 4'hF);
        // bresp is valid while bvalid is asserted; hold BREADY low for one edge.
        check(bresp===2'b10, "invalid register write returns SLVERR");

        axi_write(32'h1000_0000, 32'h0000_0000, 4'h1);
        check(display_enable===0 && animation_enable===0, "display disable operation");

        if (errors==0) begin
            $display("============================================");
            $display(" AXI4-LITE VGA REGISTER TEST PASSED");
            $display("============================================");
            $finish;
        end else $fatal(1, "AXI register errors=%0d", errors);
    end
endmodule
