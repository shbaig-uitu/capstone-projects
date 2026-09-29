// Digilent Arty A7-100T FPGA wrapper for Project 02.
// Board clock: 100 MHz single-ended oscillator on E3.
// Generates 50 MHz CPU clock and 25 MHz VGA pixel clock with a 7-series MMCM.
// VGA is exposed for the Digilent Pmod VGA through JB and JC.
module arty_a7_100t_vga_top #(
    parameter IMEM_INIT_FILE = "firmware/firmware.hex"
)(
    input wire CLK100MHZ,
    input wire btn_reset,
    output wire [3:0] led,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS
);
    wire clk100, clk50_mmcm, clk25_mmcm, clkfb, clkfb_buf;
    wire clk50, clk25, locked;
    wire rst_n;
    wire [7:0] rgb332;

    // Arty user button is active-high; project reset is active-low.
    assign rst_n = (~btn_reset) & locked;

    IBUF u_ibuf (.I(CLK100MHZ), .O(clk100));

    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKFBOUT_MULT_F(10.0),
        .DIVCLK_DIVIDE(1),
        .CLKIN1_PERIOD(10.0),
        .CLKOUT0_DIVIDE_F(20.0), // 100 MHz * 10 / 20 = 50 MHz
        .CLKOUT1_DIVIDE(40),     // 100 MHz * 10 / 40 = 25 MHz
        .STARTUP_WAIT("FALSE")
    ) u_mmcm (
        .CLKIN1(clk100),
        .CLKFBIN(clkfb_buf),
        .RST(btn_reset),
        .PWRDWN(1'b0),
        .CLKFBOUT(clkfb),
        .CLKOUT0(clk50_mmcm),
        .CLKOUT1(clk25_mmcm),
        .LOCKED(locked)
    );

    BUFG u_fb  (.I(clkfb),      .O(clkfb_buf));
    BUFG u_50  (.I(clk50_mmcm), .O(clk50));
    BUFG u_25  (.I(clk25_mmcm), .O(clk25));

    riscv_vga_soc #(.IMEM_INIT_FILE(IMEM_INIT_FILE)) u_soc (
        .clk_50mhz(clk50),
        .clk_25mhz(clk25),
        .rst_n(rst_n),
        .vga_hsync(VGA_HS),
        .vga_vsync(VGA_VS),
        .vga_rgb(rgb332),
        .debug_leds(led)
    );

    // RGB332 framebuffer -> 4-bit/channel Pmod VGA interface.
    assign VGA_R = {rgb332[7:5], rgb332[7]};
    assign VGA_G = {rgb332[4:2], rgb332[4]};
    assign VGA_B = {rgb332[1:0], rgb332[1:0]};
endmodule
