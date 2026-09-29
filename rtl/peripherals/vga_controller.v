// 640x480 VGA controller.
// The framebuffer is synchronous-read RAM. The address presented to the RAM
// is therefore the next pixel address, so that fb_rdata is the pixel for the
// current hcount/vcount immediately after the active clock edge.
module vga_controller #(
    parameter H_VISIBLE = 640,
    parameter H_FRONT   = 16,
    parameter H_SYNC    = 96,
    parameter H_BACK    = 48,
    parameter V_VISIBLE = 480,
    parameter V_FRONT   = 10,
    parameter V_SYNC    = 2,
    parameter V_BACK    = 33,
    parameter COLOR_DEPTH = 8
)(
    input wire pclk,
    input wire rst_n,
    input wire display_enable,
    output wire [$clog2(H_VISIBLE*V_VISIBLE)-1:0] fb_addr,
    input wire [COLOR_DEPTH-1:0] fb_rdata,
    input wire duck_enable,
    input wire [5:0] duck_frame,
    output wire duck_hit,
    output wire [COLOR_DEPTH-1:0] duck_rgb,
    output wire hsync,
    output wire vsync,
    output wire video_active,
    output wire [COLOR_DEPTH-1:0] rgb,
    output wire [11:0] hcount,
    output wire [11:0] vcount
);
    wire [11:0] hx;
    wire [11:0] vy;
    wire [9:0] ram_x;
    wire [8:0] ram_y;

    vga_timing #(
        .H_VISIBLE(H_VISIBLE), .H_FRONT(H_FRONT), .H_SYNC(H_SYNC), .H_BACK(H_BACK),
        .V_VISIBLE(V_VISIBLE), .V_FRONT(V_FRONT), .V_SYNC(V_SYNC), .V_BACK(V_BACK)
    ) timing (
        .pclk(pclk), .rst_n(rst_n), .display_enable(display_enable),
        .hcount(hx), .vcount(vy), .hsync(hsync), .vsync(vsync),
        .video_active(video_active)
    );

    // At the rising edge, timing advances from the previous pixel to the
    // current pixel. The RAM sees the address while the previous timing value
    // is still present, so request the pixel that will be current after the
    // edge. During blanking the address is harmless because RGB is blanked.
    assign ram_x = (hx < H_VISIBLE-1) ? (hx[9:0] + 10'd1) : 10'd0;
    assign ram_y = (hx < H_VISIBLE-1) ? vy[8:0] :
                   (vy < V_VISIBLE-1 ? (vy[8:0] + 9'd1) : 9'd0);

    pixel_address_gen #(.FRAME_WIDTH(H_VISIBLE), .FRAME_HEIGHT(V_VISIBLE)) addr_gen (
        .x(ram_x), .y(ram_y), .addr(fb_addr)
    );

    duck_renderer duck (
        .x(hx), .y(vy), .active(video_active), .enable(duck_enable),
        .frame_index(duck_frame), .hit(duck_hit), .rgb(duck_rgb)
    );

    rgb_output #(.COLOR_DEPTH(COLOR_DEPTH)) output_stage (
        .video_active(video_active), .framebuffer_pixel(fb_rdata),
        .overlay_hit(duck_hit), .overlay_pixel(duck_rgb), .rgb(rgb)
    );

    assign hcount = hx;
    assign vcount = vy;
endmodule
