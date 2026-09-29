`timescale 1ns/1ps
// Visual evidence capture for Project 02.
//
// This test keeps the 640x480 raster dimensions and sync timings intact, but
// uses a 1 MHz pixel clock so that a ten-frame animation sample completes in
// a practical simulation time. The generated PPM files are converted to PNG
// by scripts/capture_frames.sh.
module tb_vga_frame_capture;
    localparam integer W = 640;
    localparam integer H = 480;
    localparam integer FRAMES = 50;

    reg pclk = 1'b0;
    reg rst_n = 1'b0;
    reg display_enable = 1'b0;
    reg duck_enable = 1'b1;
    reg [5:0] duck_frame = 6'd0;

    wire [18:0] fb_addr;
    wire [7:0] fb_rdata;
    wire [7:0] rgb;
    wire hsync, vsync, video_active;
    wire [11:0] hcount, vcount;
    wire duck_hit;
    wire [7:0] duck_rgb;

    reg [7:0] frame_mem [0:W*H-1];
    integer i;
    integer frame_no;
    integer fd;
    integer pixels;
    integer r8, g8, b8;
    reg capturing;

    always #500 pclk = ~pclk; // 1 MHz, visual-capture-only clock

    // The production controller uses synchronous framebuffer reads. This
    // memory model follows the same read address but keeps the capture bench
    // compact. The framebuffer contents are deterministic RGB332 background.
    assign fb_rdata = (fb_addr < W*H) ? frame_mem[fb_addr] : 8'h00;

    vga_controller #(
        .H_VISIBLE(W), .H_FRONT(16), .H_SYNC(96), .H_BACK(48),
        .V_VISIBLE(H), .V_FRONT(10), .V_SYNC(2), .V_BACK(33),
        .COLOR_DEPTH(8)
    ) dut (
        .pclk(pclk), .rst_n(rst_n), .display_enable(display_enable),
        .fb_addr(fb_addr), .fb_rdata(fb_rdata),
        .duck_enable(duck_enable), .duck_frame(duck_frame),
        .duck_hit(duck_hit), .duck_rgb(duck_rgb),
        .hsync(hsync), .vsync(vsync), .video_active(video_active),
        .rgb(rgb), .hcount(hcount), .vcount(vcount)
    );

    function automatic [7:0] expand_r(input [7:0] p);
        expand_r = {p[7:5], p[7:5], p[7:6]};
    endfunction
    function automatic [7:0] expand_g(input [7:0] p);
        expand_g = {p[4:2], p[4:2], p[4:3]};
    endfunction
    function automatic [7:0] expand_b(input [7:0] p);
        expand_b = {p[1:0], p[1:0], p[1:0], p[1:0]};
    endfunction

    task automatic open_frame(input integer n);
        begin
            fd = $fopen($sformatf("sim/output/frame_%02d.ppm", n), "wb");
            if (!fd) $fatal(1, "Could not open frame output %0d", n);
            $fwrite(fd, "P6\n640 480\n255\n");
            pixels = 0;
            capturing = 1'b1;
        end
    endtask

    initial begin
        $display("============================================");
        $display(" PROJECT 02: VGA VISUAL FRAME CAPTURE");
        $display(" 640x480 raster, 1 MHz accelerated capture clock");
        $display(" 50 animation samples (frame 00..49)");
        $display("============================================");

        for (i = 0; i < W*H; i = i + 1)
            frame_mem[i] = 8'h9F;

        frame_no = 0;
        capturing = 1'b0;
        pixels = 0;
        repeat (4) @(posedge pclk);
        rst_n = 1'b1;
        display_enable = 1'b1;

        forever begin
            @(posedge pclk);
            #1;

            // Start a new image at the first visible pixel of each frame.
            if (hcount == 12'd0 && vcount == 12'd0 && !capturing) begin
                if (frame_no == FRAMES) begin
                    $display("Captured %0d frames.", FRAMES);
                    $finish;
                end
                duck_frame = frame_no[5:0];
                open_frame(frame_no);
                $display("CAPTURE: frame_%02d.ppm (animation index %0d)", frame_no, frame_no);
            end

            if (capturing && video_active) begin
                // Capture exactly the visible 640x480 region.
                r8 = expand_r(rgb);
                g8 = expand_g(rgb);
                b8 = expand_b(rgb);
                $fwrite(fd, "%c%c%c", r8, g8, b8);
                pixels = pixels + 1;

                if (pixels == W*H) begin
                    $fclose(fd);
                    capturing = 1'b0;
                    frame_no = frame_no + 1;
                    $display("CAPTURE PASS: frame %0d contains %0d pixels", frame_no-1, pixels);
                end
            end
        end
    end
endmodule
