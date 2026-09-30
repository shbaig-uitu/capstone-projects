`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "soc_if.sv"
`include "axi_seq_item.sv"
`include "mmu_event_seq_item.sv"
`include "axi_sequencer.sv"
`include "axi_driver.sv"
`include "axi_monitor.sv"
`include "mmu_monitor.sv"
`include "axi_agent.sv"
`include "mmu_agent.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "soc_env.sv"
`include "sequences/base_seq.sv"
`include "sequences/page_table_prog_seq.sv"
`include "sequences/rand_access_seq.sv"
`include "sequences/fault_seq.sv"
`include "tests/base_test.sv"
`include "tests/rand_test.sv"
`include "tests/fault_test.sv"
`include "assertions/soc_assertions.sv"

module tb_uvm_top;
  logic clk=0; always #5 clk=~clk;
  soc_if sif(clk);

  soc_top dut(
    .clk(clk), .rst_n(sif.rst_n), .core_rst_n(sif.core_rst_n),
    .s_axi_awaddr(sif.axi_awaddr), .s_axi_awvalid(sif.axi_awvalid), .s_axi_awready(sif.axi_awready),
    .s_axi_wdata(sif.axi_wdata), .s_axi_wvalid(sif.axi_wvalid), .s_axi_wready(sif.axi_wready),
    .s_axi_bresp(sif.axi_bresp), .s_axi_bvalid(sif.axi_bvalid), .s_axi_bready(sif.axi_bready),
    .s_axi_araddr(sif.axi_araddr), .s_axi_arvalid(sif.axi_arvalid), .s_axi_arready(sif.axi_arready),
    .s_axi_rdata(sif.axi_rdata), .s_axi_rresp(sif.axi_rresp), .s_axi_rvalid(sif.axi_rvalid), .s_axi_rready(sif.axi_rready),
    .led_fault(sif.led_fault), .led_hit(sif.led_hit), .led_miss(sif.led_miss), .uart_txd(sif.uart_txd)
  );

  assign sif.dmem_va=dut.dmem_va; assign sif.dmem_re=dut.dmem_re; assign sif.dmem_we=dut.dmem_we;
  assign sif.dmem_wdata=dut.dmem_wdata; assign sif.dmem_rdata=dut.dmem_rdata; assign sif.dmem_ready=dut.dmem_ready;
  assign sif.pmem_addr=dut.pmem_addr; assign sif.pmem_we=dut.pmem_we;
  assign sif.pmem_wdata=dut.pmem_wdata; assign sif.pmem_rdata=dut.pmem_rdata;
  assign sif.fault_pulse=dut.fault_pulse; assign sif.hit_pulse=dut.hit_pulse;
  assign sif.miss_pulse=dut.miss_pulse; assign sif.fault_latched=dut.fault_latched;

  soc_assertions sva(
    .clk(clk), .rst_n(sif.rst_n),
    .axi_awvalid(sif.axi_awvalid), .axi_awready(sif.axi_awready),
    .axi_wvalid(sif.axi_wvalid), .axi_wready(sif.axi_wready),
    .axi_bvalid(sif.axi_bvalid), .axi_bready(sif.axi_bready),
    .axi_arvalid(sif.axi_arvalid), .axi_arready(sif.axi_arready),
    .axi_rvalid(sif.axi_rvalid), .axi_rready(sif.axi_rready),
    .hit_pulse(sif.hit_pulse), .miss_pulse(sif.miss_pulse),
    .fault_pulse(sif.fault_pulse), .fault_latched(sif.fault_latched),
    .dmem_ready(sif.dmem_ready)
  );

  initial begin
    uvm_config_db#(virtual soc_if)::set(null,"*","vif",sif);
    $readmemh("tb/test_prog.hex", dut.u_imem.mem, 0, 10);
    run_test();
  end
endmodule
