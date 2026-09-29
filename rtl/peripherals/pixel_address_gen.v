// Pixel address generator.
// Framebuffer is linear: address = y * FRAME_WIDTH + x.
module pixel_address_gen #(
    parameter FRAME_WIDTH  = 640,
    parameter FRAME_HEIGHT = 480
)(
    input  wire [$clog2(FRAME_WIDTH)-1:0] x,
    input  wire [$clog2(FRAME_HEIGHT)-1:0] y,
    output wire [$clog2(FRAME_WIDTH*FRAME_HEIGHT)-1:0] addr
);
    assign addr = (y * FRAME_WIDTH) + x;
endmodule
