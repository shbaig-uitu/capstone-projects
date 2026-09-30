`ifndef AHB_DRIVER_SV
`define AHB_DRIVER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_transaction.sv"
`include "ahb_if.sv"

class ahb_driver extends uvm_driver #(ahb_transaction);

    `uvm_component_utils(ahb_driver)

    virtual ahb_if vif;

    function new(string name = "ahb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("AHB_DRIVER", "virtual interface not set for ahb_driver")
        end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            ahb_transaction req;
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transaction(ahb_transaction req);
        req.wait_cycles = 0;

        vif.haddr  <= req.addr;
        vif.hwrite <= req.write;
        vif.hwdata <= req.wdata;
        vif.hsize  <= req.size;
        vif.hvalid <= 1'b1;

        @(posedge vif.clk);

        while (vif.hready !== 1'b1) begin
            req.wait_cycles = req.wait_cycles + 1;
            @(posedge vif.clk);
        end

        req.rdata = vif.hrdata;
        req.resp  = vif.hresp;

        vif.hvalid <= 1'b0;
    endtask

endclass

`endif
