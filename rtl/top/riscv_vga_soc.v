// Complete Project 02 SoC top-level (simulation/FPGA friendly).
//
// CPU clock: 50 MHz
// VGA pixel clock: 25 MHz in simulation / derived from board clock in FPGA top
// Display: 640x480, RGB332, 307200-byte framebuffer
module riscv_vga_soc #(
    parameter FRAME_WIDTH = 640,
    parameter FRAME_HEIGHT = 480,
    parameter COLOR_DEPTH = 8,
    parameter DUCK_FRAME_TICKS = 5_000_000,
    parameter IMEM_INIT_FILE = "firmware/firmware.hex"
)(
    input wire clk_50mhz,
    input wire clk_25mhz,
    input wire rst_n,
    output wire vga_hsync,
    output wire vga_vsync,
    output wire [7:0] vga_rgb,
    output wire [3:0] debug_leds
);
    localparam FB_DEPTH = FRAME_WIDTH * FRAME_HEIGHT;
    localparam FB_ADDR_WIDTH = $clog2(FB_DEPTH);

    // CPU/native memory bus
    wire        mem_valid, mem_ready, mem_instr;
    wire [31:0] mem_addr, mem_wdata, mem_rdata;
    wire [3:0]  mem_wstrb;

    // SRAM interfaces
    wire        imem_valid, imem_ready;
    wire [31:0] imem_addr, imem_rdata;
    wire        dmem_valid, dmem_ready;
    wire [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    wire [3:0]  dmem_wstrb;

    // Framebuffer port A is owned by the CPU through the interconnect.
    wire [3:0] fb_we;
    wire [FB_ADDR_WIDTH-1:0] fb_addr_a, fb_addr_b;
    wire [31:0] fb_wdata;
    wire [7:0] fb_rdata_a, fb_rdata_b;

    // AXI4-Lite connection from native bus adapter to VGA register block.
    wire [31:0] awaddr, wdata, araddr, rdata;
    wire        awvalid, awready, wvalid, wready, bvalid, bready;
    wire        arvalid, arready, rvalid, rready;
    wire [3:0]  wstrb;
    wire [1:0]  bresp, rresp;

    // Display control/status signals.
    wire display_enable, animation_enable;
    wire [31:0] fb_base;
    wire video_active_25;
    wire [11:0] hcount_25, vcount_25;
    wire [5:0] anim_frame_50;
    reg [5:0] anim_frame_sync1_25, anim_frame_sync2_25;

    // 50 -> 25 MHz synchronization for control signals.
    reg display_sync1, display_sync2;
    reg animation_sync1, animation_sync2;

    // 50 MHz copies of VGA status for safe register reads.
    reg video_active_sync1, video_active_sync2;
    reg [11:0] hcount_sync1, hcount_sync2;
    reg [11:0] vcount_sync1, vcount_sync2;

    wire duck_hit;
    wire [COLOR_DEPTH-1:0] duck_rgb;

    duck_animation #(.FRAME_TICKS(DUCK_FRAME_TICKS)) anim_ctrl (
        .clk(clk_50mhz), .rst_n(rst_n), .enable(animation_enable),
        .frame_index(anim_frame_50)
    );

    always @(posedge clk_25mhz or negedge rst_n) begin
        if (!rst_n) begin
            display_sync1 <= 1'b0;
            display_sync2 <= 1'b0;
            animation_sync1 <= 1'b0;
            animation_sync2 <= 1'b0;
            anim_frame_sync1_25 <= 6'd0;
            anim_frame_sync2_25 <= 6'd0;
        end else begin
            display_sync1 <= display_enable;
            display_sync2 <= display_sync1;
            animation_sync1 <= animation_enable;
            animation_sync2 <= animation_sync1;
            anim_frame_sync1_25 <= anim_frame_50;
            anim_frame_sync2_25 <= anim_frame_sync1_25;
        end
    end

    always @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin
            video_active_sync1 <= 1'b0;
            video_active_sync2 <= 1'b0;
            hcount_sync1 <= 12'd0;
            hcount_sync2 <= 12'd0;
            vcount_sync1 <= 12'd0;
            vcount_sync2 <= 12'd0;
        end else begin
            video_active_sync1 <= video_active_25;
            video_active_sync2 <= video_active_sync1;
            hcount_sync1 <= hcount_25;
            hcount_sync2 <= hcount_sync1;
            vcount_sync1 <= vcount_25;
            vcount_sync2 <= vcount_sync1;
        end
    end

    rv32i_core #(.RESET_PC(32'h0000_0000)) cpu (
        .clk(clk_50mhz), .resetn(rst_n), .trap(),
        .mem_valid(mem_valid), .mem_instr(mem_instr), .mem_ready(mem_ready),
        .mem_addr(mem_addr), .mem_wdata(mem_wdata), .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata), .dbg_pc()
    );

    mem_interconnect #(
        .FRAME_WIDTH(FRAME_WIDTH), .FRAME_HEIGHT(FRAME_HEIGHT)
    ) bus_interconnect (
        .clk(clk_50mhz), .rst_n(rst_n),
        .mem_valid(mem_valid), .mem_ready(mem_ready), .mem_addr(mem_addr),
        .mem_wdata(mem_wdata), .mem_wstrb(mem_wstrb), .mem_rdata(mem_rdata),
        .fb_base_reg(fb_base),
        .imem_valid(imem_valid), .imem_ready(imem_ready), .imem_addr(imem_addr),
        .imem_rdata(imem_rdata),
        .dmem_valid(dmem_valid), .dmem_ready(dmem_ready), .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata), .dmem_wstrb(dmem_wstrb), .dmem_rdata(dmem_rdata),
        .fb_we(fb_we), .fb_addr(fb_addr_a), .fb_wdata(fb_wdata), .fb_rdata(fb_rdata_a),
        .vga_awaddr(awaddr), .vga_awvalid(awvalid), .vga_awready(awready),
        .vga_wdata(wdata), .vga_wstrb(wstrb), .vga_wvalid(wvalid), .vga_wready(wready),
        .vga_bresp(bresp), .vga_bvalid(bvalid), .vga_bready(bready),
        .vga_araddr(araddr), .vga_arvalid(arvalid), .vga_arready(arready),
        .vga_rdata(rdata), .vga_rresp(rresp), .vga_rvalid(rvalid), .vga_rready(rready)
    );

    // 32-KiB instruction memory and 32-KiB data memory.
    block_ram #(.ADDR_WIDTH(13), .DATA_WIDTH(32), .INIT_FILE(IMEM_INIT_FILE)) imem (
        .clk(clk_50mhz), .rst_n(rst_n), .valid(imem_valid), .ready(imem_ready),
        .addr(imem_addr[14:2]), .wdata(32'h0), .wstrb(4'h0), .rdata(imem_rdata)
    );

    block_ram #(.ADDR_WIDTH(13), .DATA_WIDTH(32)) dmem (
        .clk(clk_50mhz), .rst_n(rst_n), .valid(dmem_valid), .ready(dmem_ready),
        .addr(dmem_addr[14:2]), .wdata(dmem_wdata), .wstrb(dmem_wstrb),
        .rdata(dmem_rdata)
    );

    framebuffer_ram #(
        .ADDR_WIDTH(FB_ADDR_WIDTH), .DATA_WIDTH(COLOR_DEPTH), .DEPTH(FB_DEPTH)
    ) fb (
        .clk_a(clk_50mhz), .we_a(fb_we), .addr_a(fb_addr_a), .din_a(fb_wdata),
        .dout_a(fb_rdata_a), .clk_b(clk_25mhz), .addr_b(fb_addr_b),
        .dout_b(fb_rdata_b)
    );

    vga_controller #(
        .H_VISIBLE(FRAME_WIDTH), .V_VISIBLE(FRAME_HEIGHT),
        .COLOR_DEPTH(COLOR_DEPTH)
    ) vga (
        .pclk(clk_25mhz), .rst_n(rst_n), .display_enable(display_sync2),
        .fb_addr(fb_addr_b), .fb_rdata(fb_rdata_b),
        .duck_enable(animation_sync2), .duck_frame(anim_frame_sync2_25),
        .duck_hit(duck_hit), .duck_rgb(duck_rgb),
        .hsync(vga_hsync), .vsync(vga_vsync), .video_active(video_active_25),
        .rgb(vga_rgb), .hcount(hcount_25), .vcount(vcount_25)
    );

    axi_lite_vga_regs #(
        .FRAME_WIDTH(FRAME_WIDTH), .FRAME_HEIGHT(FRAME_HEIGHT)
    ) regs (
        .clk(clk_50mhz), .rst_n(rst_n),
        .s_axi_awaddr(awaddr), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
        .s_axi_wdata(wdata), .s_axi_wstrb(wstrb), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
        .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
        .s_axi_araddr(araddr), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
        .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready),
        .display_enable(display_enable), .fb_base(fb_base),
        .animation_enable(animation_enable), .animation_frame(anim_frame_50),
        .video_active(video_active_sync2), .hcount(hcount_sync2), .vcount(vcount_sync2)
    );

    // [3] display enabled, [2] active video, [1:0] inverted active-low syncs.
    assign debug_leds = {display_enable, video_active_sync2, ~vga_hsync, ~vga_vsync};
endmodule
