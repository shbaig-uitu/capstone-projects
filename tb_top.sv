`timescale 1ns/1ps
import uvm_pkg::*;
import systolic_pkg::*;

module tb_top;
    logic clk;

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    axi_if vif(clk);

    // DUT Instantiation
    accelerator_top #(.AW(32), .DW(32)) dut (
        .clk(clk),
        .rst(vif.rst),
        .awaddr(vif.awaddr),
        .awvalid(vif.awvalid),
        .awready(vif.awready),
        .wdata(vif.wdata),
        .wvalid(vif.wvalid),
        .wready(vif.wready),
        .bvalid(vif.bvalid),
        .bready(vif.bready),
        .araddr(vif.araddr),
        .arvalid(vif.arvalid),
        .arready(vif.arready),
        .rdata(vif.rdata),
        .rvalid(vif.rvalid),
        .rready(vif.rready)
    );

    initial begin
        vif.rst = 1'b1;
        #40;
        vif.rst = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual axi_if)::set(null, "*", "vif", vif);
        run_test("systolic_base_test");
    end
endmodule