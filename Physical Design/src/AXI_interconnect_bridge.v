`timescale 1ns / 1ps

module axi_interconnect_bridge (
    input  wire        clk,
    input  wire        reset,

    // RISC-V Core Interface
    input  wire [31:0] core_addr,
    input  wire [31:0] core_wdata,
    input  wire        core_read,
    input  wire        core_write,
    output wire [31:0] core_rdata,
    output wire        core_stall,

    // Local Data Memory Interface (< 0x4000_0000)
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    output wire        dmem_read,
    output wire        dmem_write,
    input  wire [31:0] dmem_rdata,

    // AXI4-Lite Master Control Interface (>= 0x4000_0000)
    output reg         axi_start_read,
    output reg         axi_start_write,
    output reg  [31:0] axi_addr,
    output reg  [31:0] axi_wdata,
    input  wire [31:0] axi_rdata,
    input  wire        axi_busy
);

    wire is_accel_access = (core_addr >= 32'h4000_0000) && (core_read || core_write);

    reg in_flight;

    // Combinatorially stall immediately on request, and hold until master finishes
    assign core_stall = is_accel_access && (!in_flight || axi_busy);

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            axi_start_read  <= 1'b0;
            axi_start_write <= 1'b0;
            axi_addr        <= 32'b0;
            axi_wdata       <= 32'b0;
            in_flight       <= 1'b0;
        end else begin
            if (is_accel_access && !in_flight) begin
                // Latch stable address and data immediately
                axi_addr        <= core_addr;
                axi_wdata       <= core_wdata;
                axi_start_read  <= core_read;
                axi_start_write <= core_write;
                in_flight       <= 1'b1;
            end else begin
                axi_start_read  <= 1'b0;
                axi_start_write <= 1'b0;
                // Clear in_flight only when AXI master completes
                if (in_flight && !axi_busy) begin
                    in_flight <= 1'b0;
                end
            end
        end
    end

    // Local Data Memory
    assign dmem_addr  = core_addr;
    assign dmem_wdata = core_wdata;
    assign dmem_read  = core_read  && !is_accel_access;
    assign dmem_write = core_write && !is_accel_access;

    // Return Data
    assign core_rdata = (is_accel_access) ? axi_rdata : dmem_rdata;

endmodule
