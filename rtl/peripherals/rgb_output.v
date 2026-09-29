// RGB output stage. Framebuffer pixels use RGB332 format.
// A duck overlay has priority over the framebuffer when it is active.
module rgb_output #(
    parameter COLOR_DEPTH = 8
)(
    input  wire                  video_active,
    input  wire [COLOR_DEPTH-1:0] framebuffer_pixel,
    input  wire                  overlay_hit,
    input  wire [COLOR_DEPTH-1:0] overlay_pixel,
    output wire [COLOR_DEPTH-1:0] rgb
);
    assign rgb = video_active ?
                 (overlay_hit ? overlay_pixel : framebuffer_pixel) :
                 {COLOR_DEPTH{1'b0}};
endmodule
