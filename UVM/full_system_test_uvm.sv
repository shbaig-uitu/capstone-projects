class full_system_test_uvm extends uvm_test;

    `uvm_component_utils(full_system_test_uvm)

    soc_env_uvm env;

    int pass_count;
    int fail_count;

    function new(string name = "full_system_test_uvm",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = soc_env_uvm::type_id::create("env", this);
        pass_count = 0;
        fail_count = 0;
    endfunction

    task automatic access_core(
        input  int        core_id,
        input  bit        rd,
        input  bit        wr,
        input  bit [31:0] addr,
        input  bit [31:0] data,
        output bit [31:0] rdata
    );

        core_sequence_uvm seq;

        seq = core_sequence_uvm::type_id::create(
            $sformatf("seq_core%0d_%0t", core_id, $time)
        );

        seq.do_read  = rd;
        seq.do_write = wr;
        seq.addr     = addr;
        seq.data     = data;

        if (core_id == 0)
            seq.start(env.core0_agent.sequencer);
        else
            seq.start(env.core1_agent.sequencer);

        rdata = seq.response_data;

        if (!seq.response_ready) begin
            fail_count++;
            `uvm_error("FULL_TEST",
                $sformatf("CORE%0d transaction completed without READY at ADDR=%08h",
                          core_id, addr))
        end

    endtask

    task automatic check_value(
        input string     test_name,
        input bit [31:0] actual,
        input bit [31:0] expected
    );

        if (actual === expected) begin
            pass_count++;
            `uvm_info("FULL_TEST",
                $sformatf("PASS %-25s EXPECTED=%08h ACTUAL=%08h",
                          test_name, expected, actual),
                UVM_LOW)
        end
        else begin
            fail_count++;
            `uvm_error("FULL_TEST",
                $sformatf("FAIL %-25s EXPECTED=%08h ACTUAL=%08h",
                          test_name, expected, actual))
        end

    endtask

    task run_phase(uvm_phase phase);

        bit [31:0] rdata;

        core_sequence_uvm core0_arb;
        core_sequence_uvm core1_arb;

        phase.raise_objection(this);

        // Wait until RTL reset is complete.
        wait (env.core0_agent.driver.vif.reset == 0);
        @(posedge env.core0_agent.driver.vif.clk);

        `uvm_info("FULL_TEST",
                  "===== STARTING COMPLETE SoC UVM TEST =====",
                  UVM_NONE)

        // =====================================================
        // TEST 1 : RESET / SRAM CLEARED
        // =====================================================
        `uvm_info("FULL_TEST", "TEST 1: Reset / SRAM initial value", UVM_LOW)

        access_core(0, 1, 0, 32'h0000_0000, 32'h0, rdata);
        check_value("RESET SRAM", rdata, 32'h0000_0000);

        // =====================================================
        // TEST 2 : SHARED SRAM COMMUNICATION
        // =====================================================
        `uvm_info("FULL_TEST", "TEST 2: Shared SRAM Core0 -> Core1", UVM_LOW)

        access_core(0, 0, 1, 32'h0000_0010, 32'h1234_5678, rdata);
        access_core(1, 1, 0, 32'h0000_0010, 32'h0, rdata);
        check_value("SHARED SRAM", rdata, 32'h1234_5678);

        // =====================================================
        // TEST 3 : SIMULTANEOUS REQUESTS / ARBITRATION
        // =====================================================
        `uvm_info("FULL_TEST", "TEST 3: Concurrent arbitration", UVM_LOW)

        core0_arb = core_sequence_uvm::type_id::create("core0_arb");
        core1_arb = core_sequence_uvm::type_id::create("core1_arb");

        core0_arb.do_read  = 0;
        core0_arb.do_write = 1;
        core0_arb.addr     = 32'h0000_0020;
        core0_arb.data     = 32'hAAAA_1111;

        core1_arb.do_read  = 0;
        core1_arb.do_write = 1;
        core1_arb.addr     = 32'h0000_0024;
        core1_arb.data     = 32'hBBBB_2222;

        fork
            core0_arb.start(env.core0_agent.sequencer);
            core1_arb.start(env.core1_agent.sequencer);
        join

        access_core(1, 1, 0, 32'h0000_0020, 32'h0, rdata);
        check_value("ARBITRATION CORE0", rdata, 32'hAAAA_1111);

        access_core(0, 1, 0, 32'h0000_0024, 32'h0, rdata);
        check_value("ARBITRATION CORE1", rdata, 32'hBBBB_2222);

        if (core0_arb.completion_time != core1_arb.completion_time) begin
            pass_count++;
            `uvm_info("FULL_TEST",
                $sformatf("PASS ARBITRATION ORDER: Core0=%0t Core1=%0t",
                          core0_arb.completion_time,
                          core1_arb.completion_time),
                UVM_LOW)
        end
        else begin
            fail_count++;
            `uvm_error("FULL_TEST",
                       "Both simultaneous requests completed at the same time")
        end

        // =====================================================
        // TEST 4 : ADDRESS ROUTING - SRAM
        // =====================================================
        `uvm_info("FULL_TEST", "TEST 4: SRAM address routing", UVM_LOW)

        access_core(0, 0, 1, 32'h0000_0030, 32'hCAFE_BABE, rdata);
        access_core(1, 1, 0, 32'h0000_0030, 32'h0, rdata);
        check_value("SRAM ROUTING", rdata, 32'hCAFE_BABE);

        // =====================================================
        // TEST 5 : MAILBOX CORE0 -> CORE1
        // =====================================================
        `uvm_info("FULL_TEST", "TEST 5: Mailbox communication", UVM_LOW)

        access_core(0, 0, 1, 32'h0000_1000, 32'hDEAD_BEEF, rdata);

        access_core(1, 1, 0, 32'h0000_1004, 32'h0, rdata);
        check_value("MAILBOX VALID", rdata, 32'h0000_0001);

        access_core(1, 1, 0, 32'h0000_1000, 32'h0, rdata);
        check_value("MAILBOX DATA", rdata, 32'hDEAD_BEEF);

        access_core(1, 1, 0, 32'h0000_1004, 32'h0, rdata);
        check_value("MAILBOX CLEAR", rdata, 32'h0000_0000);

        // =====================================================
        // TEST 6 : BACK-TO-BACK ACCESSES
        // =====================================================
        `uvm_info("FULL_TEST", "TEST 6: Back-to-back accesses", UVM_LOW)

        access_core(0, 0, 1, 32'h0000_0040, 32'h1111_1111, rdata);
        access_core(0, 0, 1, 32'h0000_0044, 32'h2222_2222, rdata);
        access_core(0, 0, 1, 32'h0000_0048, 32'h3333_3333, rdata);

        access_core(1, 1, 0, 32'h0000_0040, 32'h0, rdata);
        check_value("BACK2BACK 1", rdata, 32'h1111_1111);

        access_core(1, 1, 0, 32'h0000_0044, 32'h0, rdata);
        check_value("BACK2BACK 2", rdata, 32'h2222_2222);

        access_core(1, 1, 0, 32'h0000_0048, 32'h0, rdata);
        check_value("BACK2BACK 3", rdata, 32'h3333_3333);

        // =====================================================
        // TEST 7 : INVALID / UNMAPPED ADDRESS
        // =====================================================
        `uvm_info("FULL_TEST", "TEST 7: Invalid address", UVM_LOW)

        access_core(0, 1, 0, 32'h0000_3000, 32'h0, rdata);
        check_value("INVALID ADDRESS", rdata, 32'h0000_0000);

        // =====================================================
        // TEST 8 : UART / AXI-LITE PATH
        // =====================================================
        `uvm_info("FULL_TEST", "TEST 8: UART AXI-Lite access", UVM_LOW)

        // TX DATA register. Completion itself verifies delayed-ready AXI path.
        access_core(0, 0, 1, 32'h0000_2000, 32'h0000_0055, rdata);

        // STATUS register through the same UART route.
        access_core(1, 1, 0, 32'h0000_2004, 32'h0, rdata);

        pass_count++;
        `uvm_info("FULL_TEST",
            $sformatf("PASS UART/AXI-Lite transaction completed; STATUS=%08h", rdata),
            UVM_LOW)

        // Let monitors/scoreboard consume the last transaction.
        #50;

        `uvm_info("FULL_TEST_SUMMARY",
            $sformatf("PASS=%0d FAIL=%0d", pass_count, fail_count),
            UVM_NONE)

        if (fail_count == 0)
            `uvm_info("FULL_TEST",
                      "========== ALL TESTS PASSED ==========",
                      UVM_NONE)
        else
            `uvm_error("FULL_TEST",
                       "========== SOME TESTS FAILED ==========")

        phase.drop_objection(this);

    endtask

endclass
