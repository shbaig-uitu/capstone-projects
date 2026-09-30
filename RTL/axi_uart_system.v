module axi_uart_system #(
    parameter CLKS_PER_BIT = 8
)(
    input clk,
    input reset,

    
    
    

    input         req_read,
    input         req_write,

    input  [31:0] req_address,
    input  [31:0] req_write_data,
    input  [3:0]  req_write_strobe,

    
    
    

    output [31:0] resp_read_data,
    output        resp_ready,
    output        resp_error,

    
    
    

    output uart_tx_line,
    input  uart_rx_line
);

wire [31:0] m_axi_awaddr;
wire        m_axi_awvalid;
wire        m_axi_awready;

wire [31:0] m_axi_wdata;
wire [3:0]  m_axi_wstrb;
wire        m_axi_wvalid;
wire        m_axi_wready;

wire [1:0]  m_axi_bresp;
wire        m_axi_bvalid;
wire        m_axi_bready;

wire [31:0] m_axi_araddr;
wire        m_axi_arvalid;
wire        m_axi_arready;

wire [31:0] m_axi_rdata;
wire [1:0]  m_axi_rresp;
wire        m_axi_rvalid;
wire        m_axi_rready;

axi_lite_master_bridge master_bridge(

    .clk              (clk),
    .reset            (reset),

    
    .req_read         (req_read),
    .req_write        (req_write),

    .req_address      (req_address),
    .req_write_data   (req_write_data),
    .req_write_strobe (req_write_strobe),

    
    .resp_read_data   (resp_read_data),
    .resp_ready       (resp_ready),
    .resp_error       (resp_error),

    
    
    

    .m_axi_awaddr     (m_axi_awaddr),
    .m_axi_awvalid    (m_axi_awvalid),
    .m_axi_awready    (m_axi_awready),

    
    
    

    .m_axi_wdata      (m_axi_wdata),
    .m_axi_wstrb      (m_axi_wstrb),
    .m_axi_wvalid     (m_axi_wvalid),
    .m_axi_wready     (m_axi_wready),

    
    
    

    .m_axi_bresp      (m_axi_bresp),
    .m_axi_bvalid     (m_axi_bvalid),
    .m_axi_bready     (m_axi_bready),

    
    
    

    .m_axi_araddr     (m_axi_araddr),
    .m_axi_arvalid    (m_axi_arvalid),
    .m_axi_arready    (m_axi_arready),

    
    
    

    .m_axi_rdata      (m_axi_rdata),
    .m_axi_rresp      (m_axi_rresp),
    .m_axi_rvalid     (m_axi_rvalid),
    .m_axi_rready     (m_axi_rready)

);

axi_uart_slave #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
)
uart_slave (

    .clk           (clk),
    .reset         (reset),

    
    .S_AXI_AWADDR  (m_axi_awaddr),
    .S_AXI_AWVALID (m_axi_awvalid),
    .S_AXI_AWREADY (m_axi_awready),

    
    .S_AXI_WDATA   (m_axi_wdata),
    .S_AXI_WSTRB   (m_axi_wstrb),
    .S_AXI_WVALID  (m_axi_wvalid),
    .S_AXI_WREADY  (m_axi_wready),

    
    .S_AXI_BRESP   (m_axi_bresp),
    .S_AXI_BVALID  (m_axi_bvalid),
    .S_AXI_BREADY  (m_axi_bready),

    
    .S_AXI_ARADDR  (m_axi_araddr),
    .S_AXI_ARVALID (m_axi_arvalid),
    .S_AXI_ARREADY (m_axi_arready),

    
    .S_AXI_RDATA   (m_axi_rdata),
    .S_AXI_RRESP   (m_axi_rresp),
    .S_AXI_RVALID  (m_axi_rvalid),
    .S_AXI_RREADY  (m_axi_rready),

    
    .uart_tx_line  (uart_tx_line),
    .uart_rx_line  (uart_rx_line)
);

endmodule

