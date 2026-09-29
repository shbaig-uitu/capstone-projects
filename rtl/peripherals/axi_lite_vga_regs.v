// Small AXI4-Lite slave used by the RISC-V memory interconnect.
//
// Register map (base 0x1000_0000):
//   0x00 CTRL       RW  bit0 display enable, bit1 animation enable
//   0x04 STATUS     RO  bit0 video active
//   0x08 WIDTH      RO  active width (640)
//   0x0C HEIGHT     RO  active height (480)
//   0x10 FB_BASE    RW  framebuffer base address (normally 0x00010000)
//   0x14 HCOUNT     RO  current horizontal counter
//   0x18 VCOUNT     RO  current vertical counter
//   0x20 ID/STATE   RO  bit0 display, bit1 animation
//   0x24 ANIM_FRAME RO  current 0..49 animation frame
// Unsupported accesses return SLVERR so invalid configurations are visible
// during verification instead of silently succeeding.
module axi_lite_vga_regs #(
    parameter FRAME_WIDTH = 640,
    parameter FRAME_HEIGHT = 480
)(
    input wire clk,
    input wire rst_n,
    input wire [31:0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output wire s_axi_awready,
    input wire [31:0] s_axi_wdata,
    input wire [3:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output wire s_axi_wready,
    output reg [1:0] s_axi_bresp,
    output reg s_axi_bvalid,
    input wire s_axi_bready,
    input wire [31:0] s_axi_araddr,
    input wire s_axi_arvalid,
    output wire s_axi_arready,
    output reg [31:0] s_axi_rdata,
    output reg [1:0] s_axi_rresp,
    output reg s_axi_rvalid,
    input wire s_axi_rready,
    output reg display_enable,
    output reg [31:0] fb_base,
    output reg animation_enable,
    input wire [5:0] animation_frame,
    input wire video_active,
    input wire [11:0] hcount,
    input wire [11:0] vcount
);
    localparam RESP_OKAY   = 2'b00;
    localparam RESP_SLVERR = 2'b10;

    reg aw_pending, w_pending, ar_pending;
    reg [31:0] awaddr_reg, wdata_reg, araddr_reg;
    reg [3:0] wstrb_reg;

    assign s_axi_awready = !aw_pending && !s_axi_bvalid && !s_axi_rvalid;
    assign s_axi_wready  = !w_pending  && !s_axi_bvalid && !s_axi_rvalid;
    assign s_axi_arready = !ar_pending && !s_axi_rvalid && !s_axi_bvalid;

    function [31:0] apply_wstrb;
        input [31:0] oldv;
        input [31:0] newv;
        input [3:0] strb;
        begin
            apply_wstrb = oldv;
            if (strb[0]) apply_wstrb[7:0]   = newv[7:0];
            if (strb[1]) apply_wstrb[15:8]  = newv[15:8];
            if (strb[2]) apply_wstrb[23:16] = newv[23:16];
            if (strb[3]) apply_wstrb[31:24] = newv[31:24];
        end
    endfunction

    function is_valid_write;
        input [7:0] a;
        begin
            is_valid_write = (a == 8'h00) || (a == 8'h10);
        end
    endfunction

    // Framebuffer base must be 32-bit aligned. The register stores the CPU
    // address used by the native memory decoder; the physical framebuffer RAM
    // itself remains at pixel offsets 0..307199.
    function is_valid_fb_base;
        input [31:0] a;
        begin
            // Keep the programmable framebuffer entirely outside the 64 KiB
            // instruction/data SRAM window and below the VGA register window.
            is_valid_fb_base = (a[1:0] == 2'b00) &&
                               (a >= 32'h0001_0000) &&
                               (a <= 32'h0FFB_5000);
        end
    endfunction

    function [31:0] read_reg;
        input [7:0] a;
        begin
            case (a)
                8'h00: read_reg = {30'h0, animation_enable, display_enable};
                8'h04: read_reg = {31'h0, video_active};
                8'h08: read_reg = FRAME_WIDTH;
                8'h0C: read_reg = FRAME_HEIGHT;
                8'h10: read_reg = fb_base;
                8'h14: read_reg = {20'h0, hcount};
                8'h18: read_reg = {20'h0, vcount};
                8'h20: read_reg = {30'h0, animation_enable, display_enable};
                8'h24: read_reg = {26'h0, animation_frame};
                default: read_reg = 32'h0000_0000;
            endcase
        end
    endfunction

    function is_valid_read;
        input [7:0] a;
        begin
            is_valid_read = (a == 8'h00) || (a == 8'h04) ||
                            (a == 8'h08) || (a == 8'h0C) ||
                            (a == 8'h10) || (a == 8'h14) ||
                            (a == 8'h18) || (a == 8'h20) ||
                            (a == 8'h24);
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            aw_pending <= 1'b0;
            w_pending  <= 1'b0;
            ar_pending <= 1'b0;
            awaddr_reg <= 32'h0;
            wdata_reg  <= 32'h0;
            wstrb_reg  <= 4'h0;
            araddr_reg <= 32'h0;
            s_axi_bvalid <= 1'b0;
            s_axi_bresp  <= RESP_OKAY;
            s_axi_rvalid <= 1'b0;
            s_axi_rresp  <= RESP_OKAY;
            s_axi_rdata  <= 32'h0;
            display_enable <= 1'b0;
            animation_enable <= 1'b0;
            fb_base <= 32'h0001_0000;
        end else begin
            // AXI write address and write data may arrive independently.
            if (s_axi_awvalid && s_axi_awready) begin
                aw_pending <= 1'b1;
                awaddr_reg <= s_axi_awaddr;
            end
            if (s_axi_wvalid && s_axi_wready) begin
                w_pending <= 1'b1;
                wdata_reg <= s_axi_wdata;
                wstrb_reg <= s_axi_wstrb;
            end

            if (aw_pending && w_pending && !s_axi_bvalid) begin
                if (is_valid_write(awaddr_reg[7:0])) begin
                    s_axi_bresp <= RESP_OKAY;
                    case (awaddr_reg[7:0])
                        8'h00: begin
                            if (wstrb_reg[0]) begin
                                display_enable <= wdata_reg[0];
                                animation_enable <= wdata_reg[1];
                            end
                        end
                        8'h10: begin
                            if (is_valid_fb_base(apply_wstrb(fb_base, wdata_reg, wstrb_reg)))
                                fb_base <= apply_wstrb(fb_base, wdata_reg, wstrb_reg);
                            else
                                s_axi_bresp <= RESP_SLVERR;
                        end
                        default: begin end
                    endcase
                end else begin
                    s_axi_bresp <= RESP_SLVERR;
                end
                aw_pending <= 1'b0;
                w_pending  <= 1'b0;
                s_axi_bvalid <= 1'b1;
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end

            if (s_axi_arvalid && s_axi_arready) begin
                ar_pending <= 1'b1;
                araddr_reg <= s_axi_araddr;
            end
            if (ar_pending && !s_axi_rvalid) begin
                ar_pending <= 1'b0;
                s_axi_rvalid <= 1'b1;
                if (is_valid_read(araddr_reg[7:0])) begin
                    s_axi_rresp <= RESP_OKAY;
                    s_axi_rdata <= read_reg(araddr_reg[7:0]);
                end else begin
                    s_axi_rresp <= RESP_SLVERR;
                    s_axi_rdata <= 32'h0000_0000;
                end
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end
endmodule
