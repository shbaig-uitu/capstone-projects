// Lightweight hardware animated yellow-duck overlay.
// 50 logical frames, one frame every 100 ms = 10 FPS.
// The duck moves horizontally and bobs vertically; the wing changes phase.
module duck_animation #(
    parameter H_VISIBLE = 640,
    parameter V_VISIBLE = 480,
    parameter FRAME_TICKS = 5_000_000   // 50 MHz * 100 ms
)(
    input  wire clk,
    input  wire rst_n,
    input  wire enable,
    output reg [5:0] frame_index
);
    reg [22:0] tick_count;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_count <= 23'd0;
            frame_index <= 6'd0;
        end else if (!enable) begin
            tick_count <= 23'd0;
            frame_index <= 6'd0;
        end else if (tick_count == FRAME_TICKS-1) begin
            tick_count <= 23'd0;
            if (frame_index == 6'd49) frame_index <= 6'd0;
            else frame_index <= frame_index + 1'b1;
        end else begin
            tick_count <= tick_count + 1'b1;
        end
    end
endmodule

// Pixel renderer for the duck. Transparent pixels expose the framebuffer.
module duck_renderer #(
    parameter H_VISIBLE = 640,
    parameter V_VISIBLE = 480
)(
    input wire [11:0] x,
    input wire [11:0] y,
    input wire active,
    input wire enable,
    input wire [5:0] frame_index,
    output reg hit,
    output reg [7:0] rgb
);
    integer dx, dy;
    integer duck_x, duck_y;
    integer body_cx, body_cy, head_cx, head_cy;
    integer bx, by, hx, hy;
    integer wing_cx, wing_cy;
    integer wing_w;
    always @* begin
        hit = 1'b0;
        rgb = 8'h00;

        // 50 positions across the screen; 32-pixel bob.
        duck_x = 40 + (frame_index * 10);
        duck_y = 210 + ((frame_index[2:0] < 3) ? frame_index[2:0] * 4 : (6 - frame_index[2:0]) * 4);

        dx = $signed({1'b0,x}) - duck_x;
        dy = $signed({1'b0,y}) - duck_y;

        // Body: approximate ellipse centered at (24,27), radius 23x14.
        body_cx = 24; body_cy = 27;
        bx = dx - body_cx; by = dy - body_cy;
        if (((bx*bx*100)/(23*23)) + ((by*by*100)/(14*14)) <= 100) begin
            hit = active && enable;
            rgb = 8'hFC; // yellow
        end

        // Head.
        head_cx = 23; head_cy = 12;
        hx = dx - head_cx; hy = dy - head_cy;
        if ((hx*hx + hy*hy) <= 13*13) begin
            hit = active && enable;
            rgb = 8'hFC;
        end

        // Wing moves every frame: open/closed.
        wing_cx = 18; wing_cy = 28;
        wing_w = (frame_index[0] ? 11 : 7);
        if ((((dx-wing_cx)*(dx-wing_cx))*100)/(wing_w*wing_w) + (((dy-wing_cy)*(dy-wing_cy))*100)/(6*6) <= 100) begin
            hit = active && enable;
            rgb = 8'hD8;
        end

        // Orange beak.
        if ((dx >= 34) && (dx <= 45) && (dy >= 10) && (dy <= 15)) begin
            hit = active && enable;
            rgb = 8'hE0;
        end

        // Black eye.
        if (((dx-28)*(dx-28) + (dy-8)*(dy-8)) <= 2*2) begin
            hit = active && enable;
            rgb = 8'h01;
        end

        // Orange feet.
        if (((dx-14)*(dx-14) + (dy-41)*(dy-41) <= 5*5) ||
            ((dx-34)*(dx-34) + (dy-41)*(dy-41) <= 5*5)) begin
            hit = active && enable;
            rgb = 8'hE0;
        end
    end
endmodule
