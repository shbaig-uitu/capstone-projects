module vga_assertions #(
    parameter H_VISIBLE=640,
    parameter H_FRONT=16,
    parameter H_SYNC=96,
    parameter H_BACK=48,
    parameter V_VISIBLE=480,
    parameter V_FRONT=10,
    parameter V_SYNC=2,
    parameter V_BACK=33
)(
    input wire pclk,
    input wire rst_n,
    input wire display_enable,
    input wire hsync,
    input wire vsync,
    input wire video_active,
    input wire [7:0] rgb,
    input wire [11:0] hcount,
    input wire [11:0] vcount,
    input wire [$clog2(H_VISIBLE*V_VISIBLE)-1:0] fb_addr
);
    localparam HT=H_VISIBLE+H_FRONT+H_SYNC+H_BACK;
    localparam VT=V_VISIBLE+V_FRONT+V_SYNC+V_BACK;

    property h_range; @(posedge pclk) disable iff(!rst_n) hcount < HT; endproperty
    property v_range; @(posedge pclk) disable iff(!rst_n) vcount < VT; endproperty
    property active_inside; @(posedge pclk) disable iff(!rst_n)
        video_active |-> (display_enable && hcount<H_VISIBLE && vcount<V_VISIBLE); endproperty
    property blank_outside; @(posedge pclk) disable iff(!rst_n)
        !video_active |-> (rgb==8'h00); endproperty
    property fb_inside; @(posedge pclk) disable iff(!rst_n)
        video_active |-> fb_addr < H_VISIBLE*V_VISIBLE; endproperty

    assert property(h_range) else $error("VGA hcount range failed");
    assert property(v_range) else $error("VGA vcount range failed");
    assert property(active_inside) else $error("VGA active region failed");
    assert property(blank_outside) else $error("VGA blanking failed");
    assert property(fb_inside) else $error("VGA framebuffer address failed");
endmodule
