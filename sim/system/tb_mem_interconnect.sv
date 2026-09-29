`timescale 1ns/1ps
// Boundary/byte-lane test for the native CPU bus and framebuffer mapping.
module tb_mem_interconnect;
    logic clk=0, rst_n=0;
    logic mem_valid=0;
    wire mem_ready;
    logic [31:0] mem_addr=0, mem_wdata=0;
    logic [3:0] mem_wstrb=0;
    logic [31:0] fb_base_reg=32'h0001_0000;
    wire [31:0] mem_rdata;

    wire imem_valid, dmem_valid;
    wire [31:0] imem_addr,dmem_addr,dmem_wdata;
    wire [3:0] dmem_wstrb;
    logic imem_ready=1,dmem_ready=1;
    logic [31:0] imem_rdata=32'h12345678,dmem_rdata=32'hCAFEBABE;

    wire [3:0] fb_we;
    wire [18:0] fb_addr;
    wire [31:0] fb_wdata;
    wire [7:0] fb_rdata;
    logic [7:0] fb_mem [0:307199];

    wire [31:0] awaddr, wdata, araddr;
    wire awvalid,wvalid,arvalid;
    logic awready=1,wready=1,arready=1;
    wire [3:0] wstrb;
    wire bready, rready;
    wire [1:0] bresp,rresp; logic [31:0] vga_rdata=0;
    logic vga_bvalid=0,vga_rvalid=0;

    int errors=0;
    always #10 clk=~clk;
    assign fb_rdata = fb_mem[fb_addr];

    mem_interconnect #(.FRAME_WIDTH(640),.FRAME_HEIGHT(480)) dut (
        .clk(clk),.rst_n(rst_n),.mem_valid(mem_valid),.mem_ready(mem_ready),
        .fb_base_reg(fb_base_reg), .mem_addr(mem_addr),.mem_wdata(mem_wdata),.mem_wstrb(mem_wstrb),.mem_rdata(mem_rdata),
        .imem_valid(imem_valid),.imem_ready(imem_ready),.imem_addr(imem_addr),.imem_rdata(imem_rdata),
        .dmem_valid(dmem_valid),.dmem_ready(dmem_ready),.dmem_addr(dmem_addr),.dmem_wdata(dmem_wdata),
        .dmem_wstrb(dmem_wstrb),.dmem_rdata(dmem_rdata),.fb_we(fb_we),.fb_addr(fb_addr),
        .fb_wdata(fb_wdata),.fb_rdata(fb_rdata),.vga_awaddr(awaddr),.vga_awvalid(awvalid),
        .vga_awready(awready),.vga_wdata(wdata),.vga_wstrb(wstrb),.vga_wvalid(wvalid),
        .vga_wready(wready),.vga_bresp(bresp),.vga_bvalid(vga_bvalid),.vga_bready(bready),
        .vga_araddr(araddr),.vga_arvalid(arvalid),.vga_arready(arready),.vga_rdata(vga_rdata),
        .vga_rresp(rresp),.vga_rvalid(vga_rvalid),.vga_rready(rready)
    );

    integer i;
    always @(posedge clk) begin
        if (rst_n && |fb_we) begin
            if(fb_we[0]) fb_mem[fb_addr]   <= fb_wdata[7:0];
            if(fb_we[1]) fb_mem[fb_addr+1] <= fb_wdata[15:8];
            if(fb_we[2]) fb_mem[fb_addr+2] <= fb_wdata[23:16];
            if(fb_we[3]) fb_mem[fb_addr+3] <= fb_wdata[31:24];
        end
    end

    task automatic check(input bit c,input string s);
        if(c) $display("BUS PASS: %s",s);
        else begin $error("BUS FAIL: %s",s); errors++; end
    endtask

    task automatic native_write(input [31:0] a,input [31:0] d,input [3:0] st);
        begin
            @(posedge clk); mem_addr<=a; mem_wdata<=d; mem_wstrb<=st; mem_valid<=1;
            while(!mem_ready) @(posedge clk);
            @(posedge clk); mem_valid<=0; mem_wstrb<=0;
        end
    endtask

    task automatic native_read(input [31:0] a,output [31:0] d);
        begin
            @(posedge clk); mem_addr<=a; mem_wdata<=0; mem_wstrb<=0; mem_valid<=1;
            while(!mem_ready) @(posedge clk);
            d=mem_rdata;
            @(posedge clk); mem_valid<=0;
        end
    endtask

    reg [31:0] rd;
        initial begin
        $dumpfile("sim/output/mem_interconnect.vcd"); $dumpvars(0, tb_mem_interconnect);
        for(i=0;i<307200;i=i+1) fb_mem[i]=0;
        repeat(3) @(posedge clk); rst_n=1;

        native_write(32'h0001_0000,32'h11223344,4'hF);
        check(fb_mem[0]===8'h44 && fb_mem[1]===8'h33 && fb_mem[2]===8'h22 && fb_mem[3]===8'h11,
              "word write uses all four byte lanes");

        native_write(32'h0001_0005,32'h0000_AA00,4'h2);
        check(fb_mem[5]===8'hAA,"byte-lane write at framebuffer offset 5");

        native_write(32'h0001_0006,32'hBEEF0000,4'hC);
        check(fb_mem[6]===8'hEF && fb_mem[7]===8'hBE,
              "unaligned halfword byte lanes remain aligned to the containing word");

        // Verify that FB_BASE is actually used by the native memory decoder.
        fb_base_reg = 32'h0002_0000;
        native_write(32'h0002_0004,32'h0000_00CC,4'h1);
        check(fb_mem[4]===8'hCC,"programmable FB_BASE remaps CPU framebuffer access");
        native_read(32'h0002_0004,rd);
        check(rd===32'h000000CC,"readback through remapped framebuffer base");
        fb_base_reg = 32'h0001_0000;

        native_read(32'h0001_0002,rd);
        check(rd===32'h00000022,"framebuffer byte read at offset 2");
        native_read(32'h0005_AFFF,rd);
        check(rd===32'h00000000,"last valid framebuffer address readable");

        native_read(32'h0005_B000,rd);
        check(rd===32'hDEAD_BEEF,"first unmapped address returns error marker");

        native_read(32'h0000_0000,rd);
        check(rd===32'h12345678,"instruction memory route");
        native_read(32'h0000_8000,rd);
        check(rd===32'hCAFEBABE,"data memory route");

        if(errors==0) $display("============================================\n MEMORY INTERCONNECT TEST PASSED\n============================================");
        else $fatal(1,"interconnect errors=%0d",errors);
        $finish;
    end
endmodule
