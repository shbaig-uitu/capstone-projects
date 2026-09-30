`include "rv32i_soc_defines.v"

module soc_top #(
    parameter CORE0_IMEM_FILE = "",
    parameter CORE1_IMEM_FILE = ""
) (
    input  wire       clk,
    input  wire       rst_n,

    output wire        uart_tx,
    output wire [7:0]  led,

    output wire        mbox_c0_to_c1_flag,
    output wire        mbox_c1_to_c0_flag
);

    wire [31:0] c0_imem_addr;
    wire [31:0] c0_imem_rdata;
    wire [31:0] c1_imem_addr;
    wire [31:0] c1_imem_rdata;

    imem #(
        .DEPTH     (1024),
        .INIT_FILE (CORE0_IMEM_FILE)
    ) u_imem0 (
        .addr  (c0_imem_addr),
        .rdata (c0_imem_rdata)
    );

    imem #(
        .DEPTH     (1024),
        .INIT_FILE (CORE1_IMEM_FILE)
    ) u_imem1 (
        .addr  (c1_imem_addr),
        .rdata (c1_imem_rdata)
    );

    wire [31:0] m0_haddr;
    wire         m0_hwrite;
    wire [1:0]  m0_hsize;
    wire [31:0] m0_hwdata;
    wire         m0_hvalid;
    wire [31:0] m0_hrdata;
    wire         m0_hready;
    wire         m0_hresp;

    wire [31:0] m1_haddr;
    wire         m1_hwrite;
    wire [1:0]  m1_hsize;
    wire [31:0] m1_hwdata;
    wire         m1_hvalid;
    wire [31:0] m1_hrdata;
    wire         m1_hready;
    wire         m1_hresp;

    rv32i_core u_core0 (
        .clk        (clk),
        .rst_n      (rst_n),
        .imem_addr  (c0_imem_addr),
        .imem_rdata (c0_imem_rdata),
        .haddr      (m0_haddr),
        .hwrite     (m0_hwrite),
        .hsize      (m0_hsize),
        .hwdata     (m0_hwdata),
        .hvalid     (m0_hvalid),
        .hrdata     (m0_hrdata),
        .hready     (m0_hready),
        .hresp      (m0_hresp)
    );

    rv32i_core u_core1 (
        .clk        (clk),
        .rst_n      (rst_n),
        .imem_addr  (c1_imem_addr),
        .imem_rdata (c1_imem_rdata),
        .haddr      (m1_haddr),
        .hwrite     (m1_hwrite),
        .hsize      (m1_hsize),
        .hwdata     (m1_hwdata),
        .hvalid     (m1_hvalid),
        .hrdata     (m1_hrdata),
        .hready     (m1_hready),
        .hresp      (m1_hresp)
    );

    wire [31:0] s_dmem_haddr;
    wire         s_dmem_hwrite;
    wire [1:0]  s_dmem_hsize;
    wire [31:0] s_dmem_hwdata;
    wire         s_dmem_hvalid;
    wire [31:0] s_dmem_hrdata;
    wire         s_dmem_hready;
    wire         s_dmem_hresp;

    wire [31:0] s_mailbox_haddr;
    wire         s_mailbox_hwrite;
    wire [1:0]  s_mailbox_hsize;
    wire [31:0] s_mailbox_hwdata;
    wire         s_mailbox_hvalid;
    wire [31:0] s_mailbox_hrdata;
    wire         s_mailbox_hready;
    wire         s_mailbox_hresp;

    wire [31:0] s_uart_haddr;
    wire         s_uart_hwrite;
    wire [1:0]  s_uart_hsize;
    wire [31:0] s_uart_hwdata;
    wire         s_uart_hvalid;
    wire [31:0] s_uart_hrdata;
    wire         s_uart_hready;
    wire         s_uart_hresp;

    wire [31:0] s_gpio_haddr;
    wire         s_gpio_hwrite;
    wire [1:0]  s_gpio_hsize;
    wire [31:0] s_gpio_hwdata;
    wire         s_gpio_hvalid;
    wire [31:0] s_gpio_hrdata;
    wire         s_gpio_hready;
    wire         s_gpio_hresp;

    noc_interconnect u_interconnect (
        .clk               (clk),
        .rst_n             (rst_n),

        .m0_haddr          (m0_haddr),
        .m0_hwrite         (m0_hwrite),
        .m0_hsize          (m0_hsize),
        .m0_hwdata         (m0_hwdata),
        .m0_hvalid         (m0_hvalid),
        .m0_hrdata         (m0_hrdata),
        .m0_hready         (m0_hready),
        .m0_hresp          (m0_hresp),

        .m1_haddr          (m1_haddr),
        .m1_hwrite         (m1_hwrite),
        .m1_hsize          (m1_hsize),
        .m1_hwdata         (m1_hwdata),
        .m1_hvalid         (m1_hvalid),
        .m1_hrdata         (m1_hrdata),
        .m1_hready         (m1_hready),
        .m1_hresp          (m1_hresp),

        .s_dmem_haddr      (s_dmem_haddr),
        .s_dmem_hwrite     (s_dmem_hwrite),
        .s_dmem_hsize      (s_dmem_hsize),
        .s_dmem_hwdata     (s_dmem_hwdata),
        .s_dmem_hvalid     (s_dmem_hvalid),
        .s_dmem_hrdata     (s_dmem_hrdata),
        .s_dmem_hready     (s_dmem_hready),
        .s_dmem_hresp      (s_dmem_hresp),

        .s_mailbox_haddr   (s_mailbox_haddr),
        .s_mailbox_hwrite  (s_mailbox_hwrite),
        .s_mailbox_hsize   (s_mailbox_hsize),
        .s_mailbox_hwdata  (s_mailbox_hwdata),
        .s_mailbox_hvalid  (s_mailbox_hvalid),
        .s_mailbox_hrdata  (s_mailbox_hrdata),
        .s_mailbox_hready  (s_mailbox_hready),
        .s_mailbox_hresp   (s_mailbox_hresp),

        .s_uart_haddr      (s_uart_haddr),
        .s_uart_hwrite     (s_uart_hwrite),
        .s_uart_hsize      (s_uart_hsize),
        .s_uart_hwdata     (s_uart_hwdata),
        .s_uart_hvalid     (s_uart_hvalid),
        .s_uart_hrdata     (s_uart_hrdata),
        .s_uart_hready     (s_uart_hready),
        .s_uart_hresp      (s_uart_hresp),

        .s_gpio_haddr      (s_gpio_haddr),
        .s_gpio_hwrite     (s_gpio_hwrite),
        .s_gpio_hsize      (s_gpio_hsize),
        .s_gpio_hwdata     (s_gpio_hwdata),
        .s_gpio_hvalid     (s_gpio_hvalid),
        .s_gpio_hrdata     (s_gpio_hrdata),
        .s_gpio_hready     (s_gpio_hready),
        .s_gpio_hresp      (s_gpio_hresp)
    );

    shared_dmem #(
        .DEPTH (2048)
    ) u_shared_dmem (
        .clk    (clk),
        .rst_n  (rst_n),
        .haddr  (s_dmem_haddr),
        .hwrite (s_dmem_hwrite),
        .hsize  (s_dmem_hsize),
        .hwdata (s_dmem_hwdata),
        .hvalid (s_dmem_hvalid),
        .hrdata (s_dmem_hrdata),
        .hready (s_dmem_hready),
        .hresp  (s_dmem_hresp)
    );

    ic_mailbox u_mailbox (
        .clk           (clk),
        .rst_n         (rst_n),
        .haddr         (s_mailbox_haddr),
        .hwrite        (s_mailbox_hwrite),
        .hsize         (s_mailbox_hsize),
        .hwdata        (s_mailbox_hwdata),
        .hvalid        (s_mailbox_hvalid),
        .hrdata        (s_mailbox_hrdata),
        .hready        (s_mailbox_hready),
        .hresp         (s_mailbox_hresp),
        .c0_to_c1_flag (mbox_c0_to_c1_flag),
        .c1_to_c0_flag (mbox_c1_to_c0_flag)
    );

    uart_peripheral #(
        .CLKS_PER_BIT (434)
    ) u_uart (
        .clk     (clk),
        .rst_n   (rst_n),
        .haddr   (s_uart_haddr),
        .hwrite  (s_uart_hwrite),
        .hsize   (s_uart_hsize),
        .hwdata  (s_uart_hwdata),
        .hvalid  (s_uart_hvalid),
        .hrdata  (s_uart_hrdata),
        .hready  (s_uart_hready),
        .hresp   (s_uart_hresp),
        .uart_tx (uart_tx)
    );

    gpio_peripheral u_gpio (
        .clk    (clk),
        .rst_n  (rst_n),
        .haddr  (s_gpio_haddr),
        .hwrite (s_gpio_hwrite),
        .hsize  (s_gpio_hsize),
        .hwdata (s_gpio_hwdata),
        .hvalid (s_gpio_hvalid),
        .hrdata (s_gpio_hrdata),
        .hready (s_gpio_hready),
        .hresp  (s_gpio_hresp),
        .led    (led)
    );

endmodule
