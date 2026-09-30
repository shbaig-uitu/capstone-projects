`timescale 1ns / 1ps

module soc_top (
    input  wire        clk,
    input  wire        reset,          // Active-low reset

    // Instruction Memory Interface
    output wire [31:0] imem_addr,
    input  wire [31:0] imem_data
);

    // Core <-> Bridge Wires
    wire [31:0] core_mem_addr;
    wire [31:0] core_mem_wdata;
    wire        core_mem_read;
    wire        core_mem_write;
    wire [31:0] core_mem_rdata;
    wire        core_stall;

    // Bridge <-> Internal SRAM Wires
    wire [31:0] sram_addr;
    wire [31:0] sram_wdata;
    wire        sram_read;
    wire        sram_write;
    wire [31:0] sram_rdata;

    // Bridge <-> AXI Master Control Wires
    wire        axi_start_read;
    wire        axi_start_write;
    wire [31:0] axi_ctrl_addr;
    wire [31:0] axi_ctrl_wdata;
    wire [31:0] axi_ctrl_rdata;
    wire        axi_busy;

    // AXI4-Lite Bus Wires (Master <-> Systolic Slave)
    wire [31:0] m_araddr;
    wire        m_arvalid;
    wire        m_arready;
    wire [31:0] m_rdata;
    wire [1:0]  m_rresp;
    wire        m_rvalid;
    wire        m_rready;
    wire [31:0] m_awaddr;
    wire        m_awvalid;
    wire        m_awready;
    wire [31:0] m_wdata;
    wire [3:0]  m_wstrb;
    wire        m_wvalid;
    wire        m_wready;
    wire [1:0]  m_bresp;
    wire        m_bvalid;
    wire        m_bready;

    // 1. RISC-V RV32I Processor Core
    riscv_top core_u (
        .clk        (clk),
        .reset      (reset),
        .stall      (core_stall),
        .imem_addr  (imem_addr),
        .imem_data  (imem_data),
        .mem_addr   (core_mem_addr),
        .mem_wdata  (core_mem_wdata),
        .mem_read   (core_mem_read),
        .mem_write  (core_mem_write),
        .mem_rdata  (core_mem_rdata)
    );

    // 2. Interconnect & Address Decoder Bridge
    axi_interconnect_bridge bridge_u (
        .clk             (clk),
        .reset           (reset),
        .core_addr       (core_mem_addr),
        .core_wdata      (core_mem_wdata),
        .core_read       (core_mem_read),
        .core_write      (core_mem_write),
        .core_rdata      (core_mem_rdata),
        .core_stall      (core_stall),
        .dmem_addr       (sram_addr),
        .dmem_wdata      (sram_wdata),
        .dmem_read       (sram_read),
        .dmem_write      (sram_write),
        .dmem_rdata      (sram_rdata),
        .axi_start_read  (axi_start_read),
        .axi_start_write (axi_start_write),
        .axi_addr        (axi_ctrl_addr),
        .axi_wdata       (axi_ctrl_wdata),
        .axi_rdata       (axi_ctrl_rdata),
        .axi_busy        (axi_busy)
    );

    // 3. On-Chip Synthesizable Data SRAM (1KB)
    sram_memory #(
        .ADDR_WIDTH(2),
        .DATA_WIDTH(32)
    ) data_sram_u (
        .clk       (clk),
        .reset     (reset),
        .addr      (sram_addr),
        .wdata     (sram_wdata),
        .wstrb     (4'b1111),
        .mem_read  (sram_read),
        .mem_write (sram_write),
        .rdata     (sram_rdata)
    );

    // 4. AXI4-Lite Master Bridge
    axi_lite_master master_u (
        .ACLK        (clk),
        .ARESETN     (reset),
        .START_READ  (axi_start_read),
        .START_WRITE (axi_start_write),
        .address     (axi_ctrl_addr),
        .W_data      (axi_ctrl_wdata),
        .busy        (axi_busy),
        .rd_data_out (axi_ctrl_rdata),
        .ARADDR      (m_araddr),
        .ARVALID     (m_arvalid),
        .ARREADY     (m_arready),
        .RDATA       (m_rdata),
        .RRESP       (m_rresp),
        .RVALID      (m_rvalid),
        .RREADY      (m_rready),
        .AWADDR      (m_awaddr),
        .AWVALID     (m_awvalid),
        .AWREADY     (m_awready),
        .WDATA       (m_wdata),
        .WSTRB       (m_wstrb),
        .WVALID      (m_wvalid),
        .WREADY      (m_wready),
        .BRESP       (m_bresp),
        .BVALID      (m_bvalid),
        .BREADY      (m_bready)
    );

    // 5. 4x4 Systolic Array Accelerator (AXI4-Lite Slave)
    axi_systolic_top #(
        .DATA_WIDTH(8),
        .ACC_WIDTH(32)
    ) accelerator_u (
        .ACLK    (clk),
        .ARESETN (reset),
        .ARADDR  (m_araddr),
        .ARVALID (m_arvalid),
        .ARREADY (m_arready),
        .RDATA   (m_rdata),
        .RRESP   (m_rresp),
        .RVALID  (m_rvalid),
        .RREADY  (m_rready),
        .AWADDR  (m_awaddr),
        .AWVALID (m_awvalid),
        .AWREADY (m_awready),
        .WDATA   (m_wdata),
        .WSTRB   (m_wstrb),
        .WVALID  (m_wvalid),
        .WREADY  (m_wready),
        .BRESP   (m_bresp),
        .BVALID  (m_bvalid),
        .BREADY  (m_bready)
    );

endmodule
