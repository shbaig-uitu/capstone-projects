// soc_top.v - Full System-on-Chip
module soc_top (
    input clk,
    input rst
);
    // CPU Memory Bus Wires
    wire [31:0] cpu_mem_addr, cpu_mem_wdata, cpu_mem_rdata;
    wire        cpu_mem_we;
    wire [ 2:0] cpu_mem_funct3;
    wire        cpu_stall;

    // Instantiate CPU
    riscv_core cpu (
        .clk(clk), .rst(rst), .stall(cpu_stall),
        .mem_addr(cpu_mem_addr), .mem_wdata(cpu_mem_wdata),
        .mem_we(cpu_mem_we), .mem_funct3(cpu_mem_funct3),
        .mem_rdata(cpu_mem_rdata)
    );

    // Memory Map Decoding
    // 0x0000_0000 -> 0x0000_03FF : DMEM
    // 0x4000_0000 -> 0x4FFF_FFFF : Accelerator
    wire is_dmem  = (cpu_mem_addr < 32'h4000_0000);
    wire is_accel = (cpu_mem_addr >= 32'h4000_0000);

    // Determine if CPU is actually trying to read (opcode for LOAD is 7'b0000011)
    wire cpu_mem_read = (cpu.opcode == 7'b0000011);
    wire cpu_accel_req = is_accel & (cpu_mem_we | cpu_mem_read);

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
        // AXI Master Ports
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

    // Route correct read data back to CPU
    assign cpu_mem_rdata = is_accel ? bridge_rdata : dmem_rdata;

endmodule