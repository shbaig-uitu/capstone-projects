`timescale 1ns/1ps

// ============================================================
// DUAL CORE RISC-V SoC
//
// Two RV32I cores
// Two independent instruction memories (inside each core)
// Shared data resources through NoC-inspired interconnect
//
// Resources:
//   0x0000_0000 -> Shared SRAM
//   0x1000_0000 -> Mailbox
//   0x2000_0000 -> GPIO
//   0x3000_0000 -> UART
// ============================================================

module dual_core_riscv_soc #(

    parameter CORE0_PROGRAM = "core0.txt",
    parameter CORE1_PROGRAM = "core1.txt"

)(

    input wire clk,
    input wire rst,

    // ========================================================
    // GPIO OUTPUT
    // ========================================================

    output wire [31:0] gpio_out,

    // ========================================================
    // UART OUTPUT
    // ========================================================

    output wire [7:0] uart_tx_data,
    output wire       uart_tx_valid

);


    // ========================================================
    // CORE 0 MEMORY INTERFACE
    // ========================================================

    wire        core0_mem_req;
    wire        core0_mem_we;

    wire [31:0] core0_mem_addr;
    wire [31:0] core0_mem_wdata;

    wire [3:0]  core0_mem_be;

    wire [31:0] core0_mem_rdata;
    wire        core0_mem_ready;
    wire        core0_mem_error;


    // ========================================================
    // CORE 1 MEMORY INTERFACE
    // ========================================================

    wire        core1_mem_req;
    wire        core1_mem_we;

    wire [31:0] core1_mem_addr;
    wire [31:0] core1_mem_wdata;

    wire [3:0]  core1_mem_be;

    wire [31:0] core1_mem_rdata;
    wire        core1_mem_ready;
    wire        core1_mem_error;


    // ========================================================
    // RV32I CORE 0
    // ========================================================

    RV32I #(
        .PROGRAM_FILE(CORE0_PROGRAM)
    )

    core0 (

        .clk(clk),
        .rst(rst),

        // Data Memory Response
        .mem_ready(core0_mem_ready),
        .mem_rdata(core0_mem_rdata),

        // Data Memory Request
        .mem_req(core0_mem_req),
        .mem_we(core0_mem_we),
        .mem_addr(core0_mem_addr),
        .mem_wdata(core0_mem_wdata),
        .mem_be(core0_mem_be)

    );


    // ========================================================
    // RV32I CORE 1
    // ========================================================

    RV32I #(
        .PROGRAM_FILE(CORE1_PROGRAM)
    )

    core1 (

        .clk(clk),
        .rst(rst),

        // Data Memory Response
        .mem_ready(core1_mem_ready),
        .mem_rdata(core1_mem_rdata),

        // Data Memory Request
        .mem_req(core1_mem_req),
        .mem_we(core1_mem_we),
        .mem_addr(core1_mem_addr),
        .mem_wdata(core1_mem_wdata),
        .mem_be(core1_mem_be)

    );


    // ========================================================
    // AHB ADAPTER 0 SIGNALS
    // ========================================================

    wire [31:0] haddr0;
    wire [31:0] hwdata0;

    wire        hwrite0;

    wire [2:0]  hsize0;
    wire [1:0]  htrans0;

    wire [31:0] hrdata0;
    wire        hready0;
    wire        hresp0;


    // ========================================================
    // AHB ADAPTER 1 SIGNALS
    // ========================================================

    wire [31:0] haddr1;
    wire [31:0] hwdata1;

    wire        hwrite1;

    wire [2:0]  hsize1;
    wire [1:0]  htrans1;

    wire [31:0] hrdata1;
    wire        hready1;
    wire        hresp1;


    // ========================================================
    // AHB-LITE ADAPTER FOR CORE 0
    // ========================================================

    ahb_lite_adapter adapter0 (

        .clk(clk),
        .rst(rst),

        // RV32I Interface
        .core_req(core0_mem_req),
        .core_write(core0_mem_we),

        .core_addr(core0_mem_addr),
        .core_wdata(core0_mem_wdata),
        .core_be(core0_mem_be),

        .core_rdata(core0_mem_rdata),
        .core_ready(core0_mem_ready),
        .core_error(core0_mem_error),

        // AHB Interface
        .HADDR(haddr0),
        .HWDATA(hwdata0),
        .HWRITE(hwrite0),

        .HSIZE(hsize0),
        .HTRANS(htrans0),

        .HRDATA(hrdata0),
        .HREADY(hready0),
        .HRESP(hresp0)

    );


    // ========================================================
    // AHB-LITE ADAPTER FOR CORE 1
    // ========================================================

    ahb_lite_adapter adapter1 (

        .clk(clk),
        .rst(rst),

        // RV32I Interface
        .core_req(core1_mem_req),
        .core_write(core1_mem_we),

        .core_addr(core1_mem_addr),
        .core_wdata(core1_mem_wdata),
        .core_be(core1_mem_be),

        .core_rdata(core1_mem_rdata),
        .core_ready(core1_mem_ready),
        .core_error(core1_mem_error),

        // AHB Interface
        .HADDR(haddr1),
        .HWDATA(hwdata1),
        .HWRITE(hwrite1),

        .HSIZE(hsize1),
        .HTRANS(htrans1),

        .HRDATA(hrdata1),
        .HREADY(hready1),
        .HRESP(hresp1)

    );


    // ========================================================
    // NoC-INSPIRED MULTI-CORE INTERCONNECT
    // ========================================================

    noc_interconnect noc_inst (

        .clk(clk),
        .rst(rst),


        // ----------------------------------------------------
        // CORE 0 AHB MASTER
        // ----------------------------------------------------

        .haddr0(haddr0),
        .hwdata0(hwdata0),

        .hwrite0(hwrite0),
        .htrans0(htrans0),

        .hrdata0(hrdata0),
        .hready0(hready0),
        .hresp0(hresp0),


        // ----------------------------------------------------
        // CORE 1 AHB MASTER
        // ----------------------------------------------------

        .haddr1(haddr1),
        .hwdata1(hwdata1),

        .hwrite1(hwrite1),
        .htrans1(htrans1),

        .hrdata1(hrdata1),
        .hready1(hready1),
        .hresp1(hresp1),


        // ----------------------------------------------------
        // PERIPHERALS
        // ----------------------------------------------------

        .gpio_out(gpio_out),

        .uart_tx_data(uart_tx_data),
        .uart_tx_valid(uart_tx_valid)

    );


endmodule
