`ifndef AHB_SEQUENCES_SV
`define AHB_SEQUENCES_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_transaction.sv"
`include "rv32i_soc_defines.v"

class ahb_transfer_seq extends uvm_sequence #(ahb_transaction);

    `uvm_object_utils(ahb_transfer_seq)

    bit [31:0] addr;
    bit         write;
    bit [31:0] wdata;
    bit [1:0]  size;
    int         master_id;

    ahb_transaction rsp_tr;

    function new(string name = "ahb_transfer_seq");
        super.new(name);
        size = `HSIZE_WORD;
    endfunction

    task body();
        ahb_transaction tr;
        tr = ahb_transaction::type_id::create("tr");

        start_item(tr);
        tr.addr      = addr;
        tr.write     = write;
        tr.wdata     = wdata;
        tr.size      = size;
        tr.master_id = master_id;
        finish_item(tr);

        rsp_tr = tr;
    endtask

endclass

`endif
