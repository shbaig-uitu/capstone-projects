`include "rv32i_soc_defines.v"

module noc_interconnect (
    input  wire        clk,
    input  wire        rst_n,

    input  wire [31:0] m0_haddr,
    input  wire         m0_hwrite,
    input  wire [1:0]  m0_hsize,
    input  wire [31:0] m0_hwdata,
    input  wire         m0_hvalid,
    output reg  [31:0] m0_hrdata,
    output reg          m0_hready,
    output reg          m0_hresp,

    input  wire [31:0] m1_haddr,
    input  wire         m1_hwrite,
    input  wire [1:0]  m1_hsize,
    input  wire [31:0] m1_hwdata,
    input  wire         m1_hvalid,
    output reg  [31:0] m1_hrdata,
    output reg          m1_hready,
    output reg          m1_hresp,

    output reg  [31:0] s_dmem_haddr,
    output reg           s_dmem_hwrite,
    output reg  [1:0]  s_dmem_hsize,
    output reg  [31:0] s_dmem_hwdata,
    output reg           s_dmem_hvalid,
    input  wire [31:0] s_dmem_hrdata,
    input  wire         s_dmem_hready,
    input  wire         s_dmem_hresp,

    output reg  [31:0] s_mailbox_haddr,
    output reg           s_mailbox_hwrite,
    output reg  [1:0]  s_mailbox_hsize,
    output reg  [31:0] s_mailbox_hwdata,
    output reg           s_mailbox_hvalid,
    input  wire [31:0] s_mailbox_hrdata,
    input  wire         s_mailbox_hready,
    input  wire         s_mailbox_hresp,

    output reg  [31:0] s_uart_haddr,
    output reg           s_uart_hwrite,
    output reg  [1:0]  s_uart_hsize,
    output reg  [31:0] s_uart_hwdata,
    output reg           s_uart_hvalid,
    input  wire [31:0] s_uart_hrdata,
    input  wire         s_uart_hready,
    input  wire         s_uart_hresp,

    output reg  [31:0] s_gpio_haddr,
    output reg           s_gpio_hwrite,
    output reg  [1:0]  s_gpio_hsize,
    output reg  [31:0] s_gpio_hwdata,
    output reg           s_gpio_hvalid,
    input  wire [31:0] s_gpio_hrdata,
    input  wire         s_gpio_hready,
    input  wire         s_gpio_hresp
);

    wire [2:0] m0_slave_sel;
    wire        m0_addr_valid;
    wire [2:0] m1_slave_sel;
    wire        m1_addr_valid;

    addr_decoder u_addr_decoder_m0 (
        .haddr      (m0_haddr),
        .slave_sel  (m0_slave_sel),
        .addr_valid (m0_addr_valid)
    );

    addr_decoder u_addr_decoder_m1 (
        .haddr      (m1_haddr),
        .slave_sel  (m1_slave_sel),
        .addr_valid (m1_addr_valid)
    );

    wire dmem_req0    = m0_hvalid & m0_addr_valid & (m0_slave_sel == `SLAVE_DMEM);
    wire dmem_req1    = m1_hvalid & m1_addr_valid & (m1_slave_sel == `SLAVE_DMEM);
    wire mailbox_req0 = m0_hvalid & m0_addr_valid & (m0_slave_sel == `SLAVE_MAILBOX);
    wire mailbox_req1 = m1_hvalid & m1_addr_valid & (m1_slave_sel == `SLAVE_MAILBOX);
    wire uart_req0    = m0_hvalid & m0_addr_valid & (m0_slave_sel == `SLAVE_UART);
    wire uart_req1    = m1_hvalid & m1_addr_valid & (m1_slave_sel == `SLAVE_UART);
    wire gpio_req0    = m0_hvalid & m0_addr_valid & (m0_slave_sel == `SLAVE_GPIO);
    wire gpio_req1    = m1_hvalid & m1_addr_valid & (m1_slave_sel == `SLAVE_GPIO);

    wire dmem_grant0,    dmem_grant1;
    wire mailbox_grant0, mailbox_grant1;
    wire uart_grant0,    uart_grant1;
    wire gpio_grant0,    gpio_grant1;

    arbiter u_arb_dmem (
        .clk    (clk),
        .rst_n  (rst_n),
        .req0   (dmem_req0),
        .req1   (dmem_req1),
        .grant0 (dmem_grant0),
        .grant1 (dmem_grant1)
    );

    arbiter u_arb_mailbox (
        .clk    (clk),
        .rst_n  (rst_n),
        .req0   (mailbox_req0),
        .req1   (mailbox_req1),
        .grant0 (mailbox_grant0),
        .grant1 (mailbox_grant1)
    );

    arbiter u_arb_uart (
        .clk    (clk),
        .rst_n  (rst_n),
        .req0   (uart_req0),
        .req1   (uart_req1),
        .grant0 (uart_grant0),
        .grant1 (uart_grant1)
    );

    arbiter u_arb_gpio (
        .clk    (clk),
        .rst_n  (rst_n),
        .req0   (gpio_req0),
        .req1   (gpio_req1),
        .grant0 (gpio_grant0),
        .grant1 (gpio_grant1)
    );

    always @(*) begin
        if (dmem_grant0) begin
            s_dmem_haddr  = m0_haddr;
            s_dmem_hwrite = m0_hwrite;
            s_dmem_hsize  = m0_hsize;
            s_dmem_hwdata = m0_hwdata;
        end else if (dmem_grant1) begin
            s_dmem_haddr  = m1_haddr;
            s_dmem_hwrite = m1_hwrite;
            s_dmem_hsize  = m1_hsize;
            s_dmem_hwdata = m1_hwdata;
        end else begin
            s_dmem_haddr  = 32'h0000_0000;
            s_dmem_hwrite = 1'b0;
            s_dmem_hsize  = 2'b00;
            s_dmem_hwdata = 32'h0000_0000;
        end
        s_dmem_hvalid = dmem_grant0 | dmem_grant1;
    end

    always @(*) begin
        if (mailbox_grant0) begin
            s_mailbox_haddr  = m0_haddr;
            s_mailbox_hwrite = m0_hwrite;
            s_mailbox_hsize  = m0_hsize;
            s_mailbox_hwdata = m0_hwdata;
        end else if (mailbox_grant1) begin
            s_mailbox_haddr  = m1_haddr;
            s_mailbox_hwrite = m1_hwrite;
            s_mailbox_hsize  = m1_hsize;
            s_mailbox_hwdata = m1_hwdata;
        end else begin
            s_mailbox_haddr  = 32'h0000_0000;
            s_mailbox_hwrite = 1'b0;
            s_mailbox_hsize  = 2'b00;
            s_mailbox_hwdata = 32'h0000_0000;
        end
        s_mailbox_hvalid = mailbox_grant0 | mailbox_grant1;
    end

    always @(*) begin
        if (uart_grant0) begin
            s_uart_haddr  = m0_haddr;
            s_uart_hwrite = m0_hwrite;
            s_uart_hsize  = m0_hsize;
            s_uart_hwdata = m0_hwdata;
        end else if (uart_grant1) begin
            s_uart_haddr  = m1_haddr;
            s_uart_hwrite = m1_hwrite;
            s_uart_hsize  = m1_hsize;
            s_uart_hwdata = m1_hwdata;
        end else begin
            s_uart_haddr  = 32'h0000_0000;
            s_uart_hwrite = 1'b0;
            s_uart_hsize  = 2'b00;
            s_uart_hwdata = 32'h0000_0000;
        end
        s_uart_hvalid = uart_grant0 | uart_grant1;
    end

    always @(*) begin
        if (gpio_grant0) begin
            s_gpio_haddr  = m0_haddr;
            s_gpio_hwrite = m0_hwrite;
            s_gpio_hsize  = m0_hsize;
            s_gpio_hwdata = m0_hwdata;
        end else if (gpio_grant1) begin
            s_gpio_haddr  = m1_haddr;
            s_gpio_hwrite = m1_hwrite;
            s_gpio_hsize  = m1_hsize;
            s_gpio_hwdata = m1_hwdata;
        end else begin
            s_gpio_haddr  = 32'h0000_0000;
            s_gpio_hwrite = 1'b0;
            s_gpio_hsize  = 2'b00;
            s_gpio_hwdata = 32'h0000_0000;
        end
        s_gpio_hvalid = gpio_grant0 | gpio_grant1;
    end

    reg        m0_sel_grant;
    reg [31:0] m0_sel_hrdata;
    reg        m0_sel_hready;
    reg        m0_sel_hresp;

    always @(*) begin
        case (m0_slave_sel)
            `SLAVE_DMEM: begin
                m0_sel_grant  = dmem_grant0;
                m0_sel_hrdata = s_dmem_hrdata;
                m0_sel_hready = s_dmem_hready;
                m0_sel_hresp  = s_dmem_hresp;
            end
            `SLAVE_MAILBOX: begin
                m0_sel_grant  = mailbox_grant0;
                m0_sel_hrdata = s_mailbox_hrdata;
                m0_sel_hready = s_mailbox_hready;
                m0_sel_hresp  = s_mailbox_hresp;
            end
            `SLAVE_UART: begin
                m0_sel_grant  = uart_grant0;
                m0_sel_hrdata = s_uart_hrdata;
                m0_sel_hready = s_uart_hready;
                m0_sel_hresp  = s_uart_hresp;
            end
            `SLAVE_GPIO: begin
                m0_sel_grant  = gpio_grant0;
                m0_sel_hrdata = s_gpio_hrdata;
                m0_sel_hready = s_gpio_hready;
                m0_sel_hresp  = s_gpio_hresp;
            end
            default: begin
                m0_sel_grant  = 1'b0;
                m0_sel_hrdata = 32'h0000_0000;
                m0_sel_hready = 1'b0;
                m0_sel_hresp  = `HRESP_OKAY;
            end
        endcase
    end

    always @(*) begin
        if (!m0_addr_valid) begin
            m0_hready = 1'b1;
            m0_hresp  = `HRESP_ERROR;
            m0_hrdata = 32'h0000_0000;
        end else if (m0_sel_grant) begin
            m0_hready = m0_sel_hready;
            m0_hresp  = m0_sel_hresp;
            m0_hrdata = m0_sel_hrdata;
        end else begin
            m0_hready = 1'b0;
            m0_hresp  = `HRESP_OKAY;
            m0_hrdata = 32'h0000_0000;
        end
    end

    reg        m1_sel_grant;
    reg [31:0] m1_sel_hrdata;
    reg        m1_sel_hready;
    reg        m1_sel_hresp;

    always @(*) begin
        case (m1_slave_sel)
            `SLAVE_DMEM: begin
                m1_sel_grant  = dmem_grant1;
                m1_sel_hrdata = s_dmem_hrdata;
                m1_sel_hready = s_dmem_hready;
                m1_sel_hresp  = s_dmem_hresp;
            end
            `SLAVE_MAILBOX: begin
                m1_sel_grant  = mailbox_grant1;
                m1_sel_hrdata = s_mailbox_hrdata;
                m1_sel_hready = s_mailbox_hready;
                m1_sel_hresp  = s_mailbox_hresp;
            end
            `SLAVE_UART: begin
                m1_sel_grant  = uart_grant1;
                m1_sel_hrdata = s_uart_hrdata;
                m1_sel_hready = s_uart_hready;
                m1_sel_hresp  = s_uart_hresp;
            end
            `SLAVE_GPIO: begin
                m1_sel_grant  = gpio_grant1;
                m1_sel_hrdata = s_gpio_hrdata;
                m1_sel_hready = s_gpio_hready;
                m1_sel_hresp  = s_gpio_hresp;
            end
            default: begin
                m1_sel_grant  = 1'b0;
                m1_sel_hrdata = 32'h0000_0000;
                m1_sel_hready = 1'b0;
                m1_sel_hresp  = `HRESP_OKAY;
            end
        endcase
    end

    always @(*) begin
        if (!m1_addr_valid) begin
            m1_hready = 1'b1;
            m1_hresp  = `HRESP_ERROR;
            m1_hrdata = 32'h0000_0000;
        end else if (m1_sel_grant) begin
            m1_hready = m1_sel_hready;
            m1_hresp  = m1_sel_hresp;
            m1_hrdata = m1_sel_hrdata;
        end else begin
            m1_hready = 1'b0;
            m1_hresp  = `HRESP_OKAY;
            m1_hrdata = 32'h0000_0000;
        end
    end

endmodule
