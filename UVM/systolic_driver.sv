`ifndef SYSTOLIC_DRIVER_SV
`define SYSTOLIC_DRIVER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class systolic_driver extends uvm_driver #(systolic_seq_item);
  `uvm_component_utils(systolic_driver)

  // Virtual Interface Handle
  virtual systolic_if.master_mp vif;

  function new(string name = "systolic_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual systolic_if.master_mp)::get(this, "", "vif", vif)) begin
      `uvm_fatal("DRV", "Virtual interface not found in config_db!")
    end
  endfunction

  task run_phase(uvm_phase phase);
    reset_signals();
    @(posedge vif.ARESETN);
    @(posedge vif.ACLK);

    forever begin
      seq_item_port.get_next_item(req);
      drive_item(req);
      seq_item_port.item_done();
    end
  endtask

  task reset_signals();
    vif.AWADDR  <= 32'b0;
    vif.AWVALID <= 1'b0;
    vif.WDATA   <= 32'b0;
    vif.WSTRB   <= 4'b0000;
    vif.WVALID  <= 1'b0;
    vif.BREADY  <= 1'b0;
    vif.ARADDR  <= 32'b0;
    vif.ARVALID <= 1'b0;
    vif.RREADY  <= 1'b0;
  endtask

  task drive_item(systolic_seq_item item);
    if (item.op == systolic_seq_item::WRITE) begin
      drive_write(item.addr, item.data);
    end else begin
      drive_read(item.addr, item.rdata);
    end
  endtask

  task drive_write(bit [31:0] addr, bit [31:0] data);
    @(posedge vif.ACLK);
    vif.AWADDR  <= addr;
    vif.AWVALID <= 1'b1;
    vif.WDATA   <= data;
    vif.WSTRB   <= 4'b1111;
    vif.WVALID  <= 1'b1;
    vif.BREADY  <= 1'b1;

    // Wait for Address & Data handshakes
    fork
      begin
        wait(vif.AWREADY);
        @(posedge vif.ACLK);
        vif.AWVALID <= 1'b0;
      end
      begin
        wait(vif.WREADY);
        @(posedge vif.ACLK);
        vif.WVALID <= 1'b0;
      end
    join

    // Wait for Write Response
    wait(vif.BVALID);
    @(posedge vif.ACLK);
    vif.BREADY <= 1'b0;
  endtask

  task drive_read(bit [31:0] addr, output bit [31:0] data);
    @(posedge vif.ACLK);
    vif.ARADDR  <= addr;
    vif.ARVALID <= 1'b1;
    vif.RREADY  <= 1'b1;

    // Wait for Read Address handshake
    wait(vif.ARREADY);
    @(posedge vif.ACLK);
    vif.ARVALID <= 1'b0;

    // Wait for Read Data
    wait(vif.RVALID);
    data = vif.RDATA;
    @(posedge vif.ACLK);
    vif.RREADY <= 1'b0;
  endtask

endclass

`endif
