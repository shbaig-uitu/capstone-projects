`ifndef AHB_BASE_TEST_SV
`define AHB_BASE_TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ahb_env.sv"
`include "ahb_sequences.sv"
`include "rv32i_soc_defines.v"
`include "ahb_if.sv"

class ahb_base_test extends uvm_test;

    `uvm_component_utils(ahb_base_test)

    ahb_env             env;
    virtual ahb_if       vif;

    function new(string name = "ahb_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ahb_env::type_id::create("env", this);
        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif0", vif)) begin
            `uvm_fatal("AHB_TEST", "virtual interface vif0 not set for ahb_base_test")
        end
    endfunction

    task run_transfer(
        ahb_sequencer   seqr,
        bit [31:0]      addr,
        bit              write,
        bit [31:0]      wdata,
        int              master_id,
        output bit [31:0] rdata,
        output bit        resp,
        output int        wait_cycles
    );
        ahb_transfer_seq seq;
        seq = ahb_transfer_seq::type_id::create("seq");
        seq.addr      = addr;
        seq.write     = write;
        seq.wdata     = wdata;
        seq.master_id = master_id;
        seq.start(seqr);
        rdata       = seq.rsp_tr.rdata;
        resp        = seq.rsp_tr.resp;
        wait_cycles = seq.rsp_tr.wait_cycles;
    endtask

    task run_phase(uvm_phase phase);
        bit [31:0] rd0, rd1;
        bit          resp0, resp1;
        int          wc0, wc1;

        phase.raise_objection(this);

        `uvm_info("TEST", "Waiting for reset deassertion", UVM_LOW)
        wait (vif.rst_n === 1'b1);
        repeat (2) @(posedge vif.clk);

        `uvm_info("TEST", "TEST 2 : SIMULTANEOUS ACCESS / ARBITRATION TO SHARED SRAM", UVM_LOW)
        fork
            run_transfer(env.agent0.sequencer, `DMEM_BASE,     1'b1, 32'hAAAA_0000, 0, rd0, resp0, wc0);
            run_transfer(env.agent1.sequencer, `DMEM_BASE + 4, 1'b1, 32'hBBBB_1111, 1, rd1, resp1, wc1);
        join
        `uvm_info("TEST", $sformatf("wait_cycles master0=%0d master1=%0d", wc0, wc1), UVM_LOW)

        run_transfer(env.agent0.sequencer, `DMEM_BASE,     1'b0, 32'h0000_0000, 0, rd0, resp0, wc0);
        run_transfer(env.agent1.sequencer, `DMEM_BASE + 4, 1'b0, 32'h0000_0000, 1, rd1, resp1, wc1);

        `uvm_info("TEST", "TEST 2b : SIMULTANEOUS ACCESS (ROUND-ROBIN FLIP - MASTER1 SHOULD STALL THIS TIME)", UVM_LOW)
        fork
            run_transfer(env.agent0.sequencer, `DMEM_BASE + 20, 1'b1, 32'h1234_5678, 0, rd0, resp0, wc0);
            run_transfer(env.agent1.sequencer, `DMEM_BASE + 24, 1'b1, 32'h8765_4321, 1, rd1, resp1, wc1);
        join
        `uvm_info("TEST", $sformatf("wait_cycles master0=%0d master1=%0d (expect flip: 0,1)", wc0, wc1), UVM_LOW)

        fork
            run_transfer(env.agent0.sequencer, `DMEM_BASE + 20, 1'b0, 32'h0000_0000, 0, rd0, resp0, wc0);
            run_transfer(env.agent1.sequencer, `DMEM_BASE + 24, 1'b0, 32'h0000_0000, 1, rd1, resp1, wc1);
        join

        `uvm_info("TEST", "TEST 3 : MAILBOX INTER-CORE COMMUNICATION", UVM_LOW)
        run_transfer(env.agent0.sequencer, `MBOX_C0_TO_C1_DATA, 1'b1, 32'hCAFE_BABE, 0, rd0, resp0, wc0);
        run_transfer(env.agent0.sequencer, `MBOX_C0_TO_C1_FLAG, 1'b1, 32'h0000_0001, 0, rd0, resp0, wc0);
        run_transfer(env.agent1.sequencer, `MBOX_C0_TO_C1_DATA, 1'b0, 32'h0000_0000, 1, rd1, resp1, wc1);
        run_transfer(env.agent1.sequencer, `MBOX_C0_TO_C1_FLAG, 1'b0, 32'h0000_0000, 1, rd1, resp1, wc1);
        run_transfer(env.agent1.sequencer, `MBOX_C0_TO_C1_FLAG, 1'b1, 32'h0000_0000, 1, rd1, resp1, wc1);

        `uvm_info("TEST", "TEST 4 : UART PERIPHERAL BYTE TRANSMISSION", UVM_LOW)
        run_transfer(env.agent0.sequencer, `UART_TXDATA, 1'b1, 32'h0000_0041, 0, rd0, resp0, wc0);
        repeat (434 * 10 + 50) @(posedge vif.clk);
        run_transfer(env.agent0.sequencer, `UART_STATUS, 1'b0, 32'h0000_0000, 0, rd0, resp0, wc0);
        run_transfer(env.agent1.sequencer, `UART_STATUS, 1'b0, 32'h0000_0000, 1, rd1, resp1, wc1);

        `uvm_info("TEST", "TEST 5 : GPIO / LED PERIPHERAL", UVM_LOW)
        run_transfer(env.agent1.sequencer, `GPIO_LED, 1'b1, 32'h0000_00A5, 1, rd1, resp1, wc1);
        run_transfer(env.agent0.sequencer, `GPIO_LED, 1'b0, 32'h0000_0000, 0, rd0, resp0, wc0);

        `uvm_info("TEST", "TEST 6 : INVALID / UNMAPPED ADDRESS ACCESS", UVM_LOW)
        run_transfer(env.agent0.sequencer, 32'h5000_0000, 1'b0, 32'h0000_0000, 0, rd0, resp0, wc0);
        run_transfer(env.agent1.sequencer, 32'h5000_0000, 1'b1, 32'hDEAD_BEEF, 1, rd1, resp1, wc1);

        `uvm_info("TEST", "TEST 7 : BACK-TO-BACK ACCESSES (SAME MASTER)", UVM_LOW)
        run_transfer(env.agent0.sequencer, `DMEM_BASE + 8,  1'b1, 32'h1111_2222, 0, rd0, resp0, wc0);
        run_transfer(env.agent0.sequencer, `DMEM_BASE + 12, 1'b1, 32'h3333_4444, 0, rd0, resp0, wc0);
        run_transfer(env.agent0.sequencer, `DMEM_BASE + 8,  1'b0, 32'h0000_0000, 0, rd0, resp0, wc0);
        run_transfer(env.agent0.sequencer, `DMEM_BASE + 12, 1'b0, 32'h0000_0000, 0, rd0, resp0, wc0);

        `uvm_info("TEST", "TEST 8 : PARALLEL ROUTING TO DIFFERENT SLAVES (NoC PROPERTY)", UVM_LOW)
        fork
            run_transfer(env.agent0.sequencer, `DMEM_BASE + 16,     1'b1, 32'h5555_6666, 0, rd0, resp0, wc0);
            run_transfer(env.agent1.sequencer, `MBOX_C1_TO_C0_DATA, 1'b1, 32'h7777_8888, 1, rd1, resp1, wc1);
        join
        `uvm_info("TEST", $sformatf("wait_cycles master0=%0d master1=%0d (expect 0,0)", wc0, wc1), UVM_LOW)

        run_transfer(env.agent0.sequencer, `DMEM_BASE + 16,     1'b0, 32'h0000_0000, 0, rd0, resp0, wc0);
        run_transfer(env.agent1.sequencer, `MBOX_C1_TO_C0_DATA, 1'b0, 32'h0000_0000, 1, rd1, resp1, wc1);

        #100;
        phase.drop_objection(this);
    endtask

endclass

`endif
