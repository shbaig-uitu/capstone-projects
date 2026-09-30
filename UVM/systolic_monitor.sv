`ifndef SYSTOLIC_MONITOR_SV
`define SYSTOLIC_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class systolic_monitor extends uvm_monitor;
  `uvm_component_utils(systolic_monitor)

  // Virtual Interface Handle
  virtual systolic_if.monitor_mp vif;

  // Analysis Port to broadcast transactions to Scoreboard
  uvm_analysis_port #(systolic_seq_item) item_collected_port;

  function new(string name = "systolic_monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual systolic_if.monitor_mp)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON", "Virtual interface not found in config_db!")
    end
  endfunction

  task run_phase(uvm_phase phase);
    @(posedge vif.ARESETN);
    fork
      monitor_write_channel();
      monitor_read_channel();
    join
  endtask

  // Monitor Writes (Inputs to Accelerator)
  task monitor_write_channel();
    forever begin
      @(posedge vif.ACLK);
      if (vif.BVALID && vif.BREADY) begin
        systolic_seq_item trans = systolic_seq_item::type_id::create("trans_wr");
        trans.op   = systolic_seq_item::WRITE;
        trans.addr = vif.AWADDR;
        trans.data = vif.WDATA;
        trans.resp = vif.BRESP;
        item_collected_port.write(trans);
      end
    end
  endtask

  // Monitor Reads (Outputs from Accelerator)
  task monitor_read_channel();
    forever begin
      @(posedge vif.ACLK);
      if (vif.RVALID && vif.RREADY) begin
        systolic_seq_item trans = systolic_seq_item::type_id::create("trans_rd");
        trans.op    = systolic_seq_item::READ;
        trans.addr  = vif.ARADDR;
        trans.rdata = vif.RDATA;
        trans.resp  = vif.RRESP;
        item_collected_port.write(trans);
      end
    end
  endtask

endclass

`endif
