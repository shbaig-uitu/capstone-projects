interface axi_lite_if(input logic clk);
    logic rst_n;

    logic [31:0] awaddr;
    logic awvalid, awready;
    logic [31:0] wdata;
    logic [3:0] wstrb;
    logic wvalid, wready;
    logic [1:0] bresp;
    logic bvalid, bready;

    logic [31:0] araddr;
    logic arvalid, arready;
    logic [31:0] rdata;
    logic [1:0] rresp;
    logic rvalid, rready;

    // Observed VGA signals are included so the UVM test can check the
    // display-enable behavior without reaching inside the DUT.
    logic vga_hsync, vga_vsync;
    logic [7:0] vga_rgb;
    logic vga_active;
    logic [11:0] hcount, vcount;
endinterface
