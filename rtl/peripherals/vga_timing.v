// VGA timing generator for 640x480 @ 60 Hz.
// The nominal VGA pixel clock is 25.175 MHz. The project uses 25 MHz in
// simulation and generates approximately the same 60 Hz refresh rate.
module vga_timing #(
    parameter H_VISIBLE = 640,
    parameter H_FRONT   = 16,
    parameter H_SYNC    = 96,
    parameter H_BACK    = 48,
    parameter V_VISIBLE = 480,
    parameter V_FRONT   = 10,
    parameter V_SYNC    = 2,
    parameter V_BACK    = 33
)(
    input  wire       pclk,
    input  wire       rst_n,
    input  wire       display_enable,
    output reg [11:0] hcount,
    output reg [11:0] vcount,
    output wire       hsync,
    output wire       vsync,
    output wire       video_active
);
    localparam H_TOTAL = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;
    localparam V_TOTAL = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            hcount <= 12'd0;
            vcount <= 12'd0;
        end else if (hcount == H_TOTAL-1) begin
            hcount <= 12'd0;
            if (vcount == V_TOTAL-1)
                vcount <= 12'd0;
            else
                vcount <= vcount + 12'd1;
        end else begin
            hcount <= hcount + 12'd1;
        end
    end

    // VGA sync pulses are active low.
    assign hsync = !((hcount >= H_VISIBLE + H_FRONT) &&
                      (hcount <  H_VISIBLE + H_FRONT + H_SYNC));
    assign vsync = !((vcount >= V_VISIBLE + V_FRONT) &&
                      (vcount <  V_VISIBLE + V_FRONT + V_SYNC));

    // Disabling the display blanks RGB, but synchronization keeps running.
    assign video_active = display_enable &&
                          (hcount < H_VISIBLE) &&
                          (vcount < V_VISIBLE);
endmodule
