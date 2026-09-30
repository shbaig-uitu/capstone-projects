`ifndef AHB_MONITOR_SV
`define AHB_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_transaction.sv"
`include "ahb_if.sv"

class ahb_monitor extends uvm_component;

    `uvm_component_utils(ahb_monitor)

    virtual ahb_if vif;
    int master_id;

    uvm_analysis_port #(ahb_transaction) ap;

    function new(string name = "ahb_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("AHB_MONITOR", "virtual interface not set for ahb_monitor")
        end
        if (!uvm_config_db#(int)::get(this, "", "master_id", master_id)) begin
            master_id = 0;
        end
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        int wait_cnt;
        ahb_transaction tr;

        wait_cnt = 0;

        forever begin
            @(posedge vif.clk);
            if (vif.hvalid) begin
                if (vif.hready) begin
                    tr = ahb_transaction::type_id::create("tr");
                    tr.addr        = vif.haddr;
                    tr.write       = vif.hwrite;
                    tr.wdata       = vif.hwdata;
                    tr.size        = vif.hsize;
                    tr.rdata       = vif.hrdata;
                    tr.resp        = vif.hresp;
                    tr.wait_cycles = wait_cnt;
                    tr.master_id   = master_id;
                    ap.write(tr);
                    wait_cnt = 0;
                end else begin
                    wait_cnt = wait_cnt + 1;
                end
            end
        end
    endtask

endclass

`endif
