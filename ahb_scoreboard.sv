`ifndef AHB_SCOREBOARD_SV
`define AHB_SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_transaction.sv"
`include "rv32i_soc_defines.v"

class ahb_scoreboard extends uvm_component;

    `uvm_component_utils(ahb_scoreboard)

    uvm_analysis_imp #(ahb_transaction, ahb_scoreboard) analysis_export;

    bit [31:0] mem_model [bit [31:0]];

    int pass_count;
    int fail_count;

    function new(string name = "ahb_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
        pass_count = 0;
        fail_count = 0;
    endfunction

    function void write(ahb_transaction tr);
        bit is_dmem;
        bit is_mailbox;
        bit is_uart;
        bit is_gpio;
        bit is_mapped;
        bit [31:0] expected;

        is_dmem    = (tr.addr >= `DMEM_BASE)    && (tr.addr <= `DMEM_END);
        is_mailbox = (tr.addr >= `MAILBOX_BASE) && (tr.addr <= `MAILBOX_END);
        is_uart    = (tr.addr >= `UART_BASE)    && (tr.addr <= `UART_END);
        is_gpio    = (tr.addr >= `GPIO_BASE)    && (tr.addr <= `GPIO_END);
        is_mapped  = is_dmem | is_mailbox | is_uart | is_gpio;

        if (!is_mapped) begin
            if (tr.resp == `HRESP_ERROR) begin
                pass_count = pass_count + 1;
                `uvm_info("SCOREBOARD", $sformatf(
                    "[PASS] master%0d unmapped addr 0x%08h correctly returned HRESP_ERROR",
                    tr.master_id, tr.addr), UVM_LOW)
            end else begin
                fail_count = fail_count + 1;
                `uvm_error("SCOREBOARD", $sformatf(
                    "[FAIL] master%0d unmapped addr 0x%08h did NOT return HRESP_ERROR",
                    tr.master_id, tr.addr))
            end
            return;
        end

        if (tr.resp == `HRESP_ERROR) begin
            fail_count = fail_count + 1;
            `uvm_error("SCOREBOARD", $sformatf(
                "[FAIL] master%0d mapped addr 0x%08h unexpectedly returned HRESP_ERROR",
                tr.master_id, tr.addr))
            return;
        end

        if (is_uart) begin
            pass_count = pass_count + 1;
            `uvm_info("SCOREBOARD", $sformatf(
                "[PASS] master%0d uart access addr 0x%08h write=%0b (dynamic peripheral, not data-modeled)",
                tr.master_id, tr.addr, tr.write), UVM_LOW)
            return;
        end

        if (tr.write) begin
            mem_model[tr.addr] = tr.wdata;
            pass_count = pass_count + 1;
            `uvm_info("SCOREBOARD", $sformatf(
                "[PASS] master%0d wrote addr 0x%08h data=0x%08h (model updated)",
                tr.master_id, tr.addr, tr.wdata), UVM_LOW)
        end else begin
            expected = mem_model.exists(tr.addr) ? mem_model[tr.addr] : 32'h0000_0000;
            if (tr.rdata === expected) begin
                pass_count = pass_count + 1;
                `uvm_info("SCOREBOARD", $sformatf(
                    "[PASS] master%0d read addr 0x%08h got=0x%08h expected=0x%08h",
                    tr.master_id, tr.addr, tr.rdata, expected), UVM_LOW)
            end else begin
                fail_count = fail_count + 1;
                `uvm_error("SCOREBOARD", $sformatf(
                    "[FAIL] master%0d read addr 0x%08h got=0x%08h expected=0x%08h",
                    tr.master_id, tr.addr, tr.rdata, expected))
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD", $sformatf(
            "SCOREBOARD SUMMARY : PASS=%0d  FAIL=%0d", pass_count, fail_count), UVM_LOW)
    endfunction

endclass

`endif
