// soc_top.v - Full System-on-Chip with MMIO LEDs
module soc_top (
    input  wire       clk,
    input  wire       rst,
    output reg  [3:0] led,
    output wire       accel_computing,
    output wire       accel_done,
    output wire [31:0] cpu_x7,
    output wire [31:0] cpu_x8,
    output wire [31:0] c00_out
);
    // CPU Memory Bus Wires
    wire [31:0] cpu_mem_addr, cpu_mem_wdata, cpu_mem_rdata;
    wire        cpu_mem_we;
    wire        cpu_mem_read;
    wire [ 2:0] cpu_mem_funct3;
    wire        cpu_stall;

    // Instantiate CPU
    riscv_core cpu (
        .clk(clk), .rst(rst), .stall(cpu_stall),
        .mem_addr(cpu_mem_addr), .mem_wdata(cpu_mem_wdata),
        .mem_we(cpu_mem_we), .mem_read(cpu_mem_read),
        .mem_funct3(cpu_mem_funct3),
        .mem_rdata(cpu_mem_rdata),
        .cpu_x7(cpu_x7),
        .cpu_x8(cpu_x8)
    );

    // Memory Map Decoding
    // 0x0000_0000 -> 0x0000_03FF : DMEM
    // 0x1000_0000                : MMIO LEDs
    // 0x4000_0000 -> 0x4FFF_FFFF : Accelerator
    wire is_dmem  = (cpu_mem_addr < 32'h1000_0000);
    wire is_led   = (cpu_mem_addr == 32'h1000_0000);
    wire is_accel = (cpu_mem_addr >= 32'h4000_0000);

    // LED MMIO Register (Active High)
    always @(posedge clk) begin
        if (rst) begin
            led <= 4'b0000;
        end else if (cpu_mem_we && is_led) begin
            led <= cpu_mem_wdata[3:0];
        end
    end

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
        .rdata(rdata), .rvalid(rvalid), .rready(rready),
        .computing_out(accel_computing),
        .done_out(accel_done),
        .c00_out(c00_out)
    );

    // Route correct read data back to CPU
    assign cpu_mem_rdata = is_accel ? bridge_rdata :
                           is_led   ? {28'b0, led} : dmem_rdata;

endmodule