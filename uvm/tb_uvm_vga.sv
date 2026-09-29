`timescale 1ns/1ps
module tb_uvm_vga;
    import uvm_pkg::*;
    import vga_uvm_pkg::*;

    logic clk=0;
    always #20 clk=~clk;

    axi_lite_if vif(clk);
    native_mem_if mem_vif(clk);

    wire display_enable, animation_enable;
    wire [31:0] fb_base;
    logic [5:0] animation_frame=0;
    wire vga_hsync,vga_vsync,vga_active;
    wire [7:0] vga_rgb;
    wire [11:0] hcount,vcount;
    wire [18:0] fb_addr;
    wire [7:0] fb_rdata;

    // Native CPU-side bus and real framebuffer path used by the UVM memory agent.
    wire imem_valid, dmem_valid;
    wire imem_ready=1'b1, dmem_ready=1'b1;
    wire [31:0] imem_addr, dmem_addr, dmem_wdata;
    wire [31:0] imem_rdata=32'h00000013, dmem_rdata=32'h0;
    wire [3:0] dmem_wstrb;
    wire [3:0] fb_we;
    wire [18:0] fb_addr_a;
    wire [31:0] fb_wdata;
    wire [7:0] fb_rdata_a;
    wire [31:0] vga_awaddr, vga_wdata, vga_araddr;
    wire [31:0] vga_rdata=32'h0;
    wire [3:0] vga_wstrb;
    wire [1:0] vga_bresp=2'b00, vga_rresp=2'b00;
    wire vga_awvalid, vga_wvalid, vga_arvalid;
    wire vga_bready, vga_rready;
    wire vga_awready=1'b1, vga_wready=1'b1, vga_bvalid=1'b0;
    wire vga_arready=1'b1, vga_rvalid=1'b0;

    assign mem_vif.rst_n = vif.rst_n;

    mem_interconnect mem_dut (
        .clk(clk), .rst_n(vif.rst_n),
        .mem_valid(mem_vif.mem_valid), .mem_ready(mem_vif.mem_ready),
        .mem_addr(mem_vif.mem_addr), .mem_wdata(mem_vif.mem_wdata),
        .mem_wstrb(mem_vif.mem_wstrb), .mem_rdata(mem_vif.mem_rdata),
        .fb_base_reg(fb_base),
        .imem_valid(imem_valid), .imem_ready(imem_ready), .imem_addr(imem_addr), .imem_rdata(imem_rdata),
        .dmem_valid(dmem_valid), .dmem_ready(dmem_ready), .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata), .dmem_wstrb(dmem_wstrb), .dmem_rdata(dmem_rdata),
        .fb_we(fb_we), .fb_addr(fb_addr_a), .fb_wdata(fb_wdata), .fb_rdata(fb_rdata_a),
        .vga_awaddr(vga_awaddr), .vga_awvalid(vga_awvalid), .vga_awready(vga_awready),
        .vga_wdata(vga_wdata), .vga_wstrb(vga_wstrb), .vga_wvalid(vga_wvalid), .vga_wready(vga_wready),
        .vga_bresp(vga_bresp), .vga_bvalid(vga_bvalid), .vga_bready(vga_bready),
        .vga_araddr(vga_araddr), .vga_arvalid(vga_arvalid), .vga_arready(vga_arready),
        .vga_rdata(vga_rdata), .vga_rresp(vga_rresp), .vga_rvalid(vga_rvalid), .vga_rready(vga_rready)
    );

    framebuffer_ram #(.DEPTH(307200)) fb_dut (
        .clk_a(clk), .we_a(fb_we), .addr_a(fb_addr_a), .din_a(fb_wdata), .dout_a(fb_rdata_a),
        .clk_b(clk), .addr_b(fb_addr), .dout_b(fb_rdata)
    );

    axi_lite_vga_regs regs (
        .clk(clk),.rst_n(vif.rst_n),
        .s_axi_awaddr(vif.awaddr),.s_axi_awvalid(vif.awvalid),.s_axi_awready(vif.awready),
        .s_axi_wdata(vif.wdata),.s_axi_wstrb(vif.wstrb),.s_axi_wvalid(vif.wvalid),.s_axi_wready(vif.wready),
        .s_axi_bresp(vif.bresp),.s_axi_bvalid(vif.bvalid),.s_axi_bready(vif.bready),
        .s_axi_araddr(vif.araddr),.s_axi_arvalid(vif.arvalid),.s_axi_arready(vif.arready),
        .s_axi_rdata(vif.rdata),.s_axi_rresp(vif.rresp),.s_axi_rvalid(vif.rvalid),.s_axi_rready(vif.rready),
        .display_enable(display_enable),.fb_base(fb_base),.animation_enable(animation_enable),
        .animation_frame(animation_frame),.video_active(vga_active),.hcount(hcount),.vcount(vcount)
    );

    vga_controller vga (
        .pclk(clk),.rst_n(vif.rst_n),.display_enable(display_enable),
        .fb_addr(fb_addr),.fb_rdata(fb_rdata),.duck_enable(animation_enable),
        .duck_frame(animation_frame),.duck_hit(),.duck_rgb(),.hsync(vga_hsync),
        .vsync(vga_vsync),.video_active(vga_active),.rgb(vga_rgb),.hcount(hcount),.vcount(vcount)
    );

    assign vif.vga_hsync=vga_hsync; assign vif.vga_vsync=vga_vsync;
    assign vif.vga_rgb=vga_rgb; assign vif.vga_active=vga_active;
    assign vif.hcount=hcount; assign vif.vcount=vcount;

        initial begin
        vif.rst_n=0;
        vif.awvalid=0; vif.wvalid=0; vif.arvalid=0; vif.bready=0; vif.rready=0;
        vif.awaddr=0; vif.wdata=0; vif.wstrb=0; vif.araddr=0;
        mem_vif.mem_valid=0; mem_vif.mem_instr=0; mem_vif.mem_addr=0;
        mem_vif.mem_wdata=0; mem_vif.mem_wstrb=0;

        uvm_config_db#(virtual axi_lite_if)::set(null,"*","vif",vif);
        uvm_config_db#(virtual native_mem_if)::set(null,"*","mem_vif",mem_vif);

        run_test("vga_uvm_test");
    end

    initial begin
        repeat(5) @(posedge clk);
        vif.rst_n=1;
    end

    vga_assertions assertions (
        .pclk(clk),.rst_n(vif.rst_n),.display_enable(display_enable),
        .hsync(vga_hsync),.vsync(vga_vsync),.video_active(vga_active),
        .rgb(vga_rgb),.hcount(hcount),.vcount(vcount),.fb_addr(fb_addr)
    );
endmodule
