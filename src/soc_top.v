// soc_top.v (Clean Interface - Leaves riscv_core untouched)
`default_nettype none

module soc_top (
    input  wire        clk,
    input  wire        rst,
    output wire        uart_tx_pin
);
    // CPU Memory Bus Wires
// CPU Memory Bus Wires
    wire [31:0] cpu_mem_addr, cpu_mem_wdata;
    reg  [31:0] cpu_mem_rdata;
    wire        cpu_mem_we;
    wire [ 2:0] cpu_mem_funct3;
    wire        cpu_stall;

    // Instantiate your original, untouched RISC-V Core
    riscv_core cpu (
        .clk(clk), .rst(rst), .stall(cpu_stall),
        .mem_addr(cpu_mem_addr), .mem_wdata(cpu_mem_wdata),
        .mem_we(cpu_mem_we), .mem_funct3(cpu_mem_funct3),
        .mem_rdata(cpu_mem_rdata)
    );

    // Extract instruction and opcode safely at the SoC level for memory mapping
    // (Assuming your core instantiates imem internally, we look at the address bus)
    // Memory Map Decoding
    wire is_dmem  = (cpu_mem_addr < 32'h4000_0000);
    wire is_accel = (cpu_mem_addr >= 32'h4000_0000 && cpu_mem_addr < 32'h5000_0000);
    wire is_uart  = (cpu_mem_addr == 32'h5000_0000);

    // Treat any access to the accelerator space as a valid request for our 14-instr loop
    wire cpu_accel_req = is_accel;

    // DMEM
    wire [31:0] dmem_rdata;
    dmem dmem0 (
        .clk(clk), .we(cpu_mem_we & is_dmem),
        .addr(cpu_mem_addr), .wdata(cpu_mem_wdata),
        .funct3(cpu_mem_funct3), .rdata(dmem_rdata)
    );

    // AXI4-Lite Wires
    wire [31:0] awaddr, wdata, araddr, rdata;
    wire awvalid, awready, wvalid, wready, bvalid, bready;
    wire arvalid, arready, rvalid, rready;
    wire [31:0] bridge_rdata;

    // CPU to AXI4-Lite Bridge
    axi4lite_master_bridge bridge (
        .clk(clk), .rst(rst),
        .cpu_req(cpu_accel_req), .cpu_addr(cpu_mem_addr),
        .cpu_wdata(cpu_mem_wdata), .cpu_we(cpu_mem_we),
        .cpu_rdata(bridge_rdata), .cpu_stall(cpu_stall),
        .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
        .wdata(wdata), .wvalid(wvalid), .wready(wready),
        .bvalid(bvalid), .bready(bready),
        .araddr(araddr), .arvalid(arvalid), .arready(arready),
        .rdata(rdata), .rvalid(rvalid), .rready(rready)
    );

    // Systolic Array Accelerator
    accelerator_top accel (
        .clk(clk), .rst(rst),
        .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
        .wdata(wdata), .wvalid(wvalid), .wready(wready),
        .bvalid(bvalid), .bready(bready),
        .araddr(araddr), .arvalid(arvalid), .arready(arready),
        .rdata(rdata), .rvalid(rvalid), .rready(rready)
    );

    // UART Transmitter module for physical output
    wire uart_busy;
    uart_tx uart_mod ( 
        .clk(clk), .rst(rst),
        .tx_en(is_uart && cpu_mem_we),
        .tx_data(cpu_mem_wdata[7:0]),
        .tx_pin(uart_tx_pin),
        .tx_busy(uart_busy)
    );

    // Route correct read data back to CPU
    always @(*) begin
        if (is_accel) cpu_mem_rdata = bridge_rdata;
        else if (is_uart) cpu_mem_rdata = {31'd0, uart_busy};
        else cpu_mem_rdata = dmem_rdata;
    end


endmodule
`default_nettype wire
