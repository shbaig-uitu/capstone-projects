`timescale 1ns/1ps

// ================================================================
// tb_noc_interconnect.v  -  STEP 2 (self-checking version)
//
// Directed, self-checking SystemVerilog testbench for the
// NoC-inspired multi-core interconnect (noc_interconnect.v).
//
// Covers:
//   - Reset behaviour
//   - Normal access: shared SRAM, mailbox, GPIO, UART
//   - Simultaneous requests / round-robin arbitration (contention)
//   - Back-to-back accesses
//   - Invalid / unmapped address
//
// Every check below compares an EXPECTED value against the
// ACTUAL value read from the DUT and prints PASS/FAIL. A running
// counter reports a final summary at the end of simulation.
// ================================================================

module tb_noc_interconnect;

    // ============================================================
    // PASS / FAIL BOOKKEEPING
    // ============================================================
    integer pass_count;
    integer fail_count;

    task automatic check_equal;
        input [255:0] test_name;   // string label (packed)
        input [31:0]  expected;
        input [31:0]  actual;
        begin
            if (expected === actual) begin
                pass_count = pass_count + 1;
                $display("PASS | %0s | expected = %h | actual = %h",
                          test_name, expected, actual);
            end
            else begin
                fail_count = fail_count + 1;
                $display("FAIL | %0s | expected = %h | actual = %h",
                          test_name, expected, actual);
            end
        end
    endtask

    task automatic check_bit;
        input [255:0] test_name;
        input         expected;
        input         actual;
        begin
            if (expected === actual) begin
                pass_count = pass_count + 1;
                $display("PASS | %0s | expected = %b | actual = %b",
                          test_name, expected, actual);
            end
            else begin
                fail_count = fail_count + 1;
                $display("FAIL | %0s | expected = %b | actual = %b",
                          test_name, expected, actual);
            end
        end
    endtask

    // ============================================================
    // CLOCK AND RESET
    // ============================================================
    reg clk;
    reg rst;

    // ============================================================
    // CORE 0 AHB SIGNALS
    // ============================================================
    reg  [31:0] haddr0;
    reg  [31:0] hwdata0;
    reg         hwrite0;
    reg  [1:0]  htrans0;

    wire [31:0] hrdata0;
    wire        hready0;
    wire        hresp0;

    // ============================================================
    // CORE 1 AHB SIGNALS
    // ============================================================
    reg  [31:0] haddr1;
    reg  [31:0] hwdata1;
    reg         hwrite1;
    reg  [1:0]  htrans1;

    wire [31:0] hrdata1;
    wire        hready1;
    wire        hresp1;

    // ============================================================
    // PERIPHERAL OUTPUTS
    // ============================================================
    wire [31:0] gpio_out;
    wire [7:0]  uart_tx_data;
    wire        uart_tx_valid;

    // ============================================================
    // DUT
    // ============================================================
    noc_interconnect dut (
        .clk(clk),
        .rst(rst),

        .haddr0(haddr0),
        .hwdata0(hwdata0),
        .hwrite0(hwrite0),
        .htrans0(htrans0),

        .hrdata0(hrdata0),
        .hready0(hready0),
        .hresp0(hresp0),

        .haddr1(haddr1),
        .hwdata1(hwdata1),
        .hwrite1(hwrite1),
        .htrans1(htrans1),

        .hrdata1(hrdata1),
        .hready1(hready1),
        .hresp1(hresp1),

        .gpio_out(gpio_out),

        .uart_tx_data(uart_tx_data),
        .uart_tx_valid(uart_tx_valid)
    );

    // ============================================================
    // CLOCK GENERATION
    // ============================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // BUS-FUNCTIONAL TASKS  (blocking, one master at a time)
    // ============================================================

    task automatic core0_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            haddr0  = addr;
            hwdata0 = data;
            hwrite0 = 1'b1;
            htrans0 = 2'b10;

            wait (hready0 == 1'b1);
            @(posedge clk);

            htrans0 = 2'b00;
            hwrite0 = 1'b0;
        end
    endtask

    task automatic core0_read;
        input  [31:0] addr;
        output [31:0] data;
        output        resp_error;
        begin
            @(posedge clk);
            haddr0  = addr;
            hwrite0 = 1'b0;
            htrans0 = 2'b10;

            wait (hready0 == 1'b1);
            data       = hrdata0;
            resp_error = hresp0;

            @(posedge clk);
            htrans0 = 2'b00;
        end
    endtask

    task automatic core1_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            haddr1  = addr;
            hwdata1 = data;
            hwrite1 = 1'b1;
            htrans1 = 2'b10;

            wait (hready1 == 1'b1);
            @(posedge clk);

            htrans1 = 2'b00;
            hwrite1 = 1'b0;
        end
    endtask

    task automatic core1_read;
        input  [31:0] addr;
        output [31:0] data;
        output        resp_error;
        begin
            @(posedge clk);
            haddr1  = addr;
            hwrite1 = 1'b0;
            htrans1 = 2'b10;

            wait (hready1 == 1'b1);
            data       = hrdata1;
            resp_error = hresp1;

            @(posedge clk);
            htrans1 = 2'b00;
        end
    endtask

    // ============================================================
    // MAIN TEST SEQUENCE
    // ============================================================
    reg [31:0] rdata;
    reg        rerr;

    integer i;

    initial begin

        pass_count = 0;
        fail_count = 0;

        // Defaults
        rst = 1'b1;

        haddr0  = 32'b0; hwdata0 = 32'b0; hwrite0 = 1'b0; htrans0 = 2'b00;
        haddr1  = 32'b0; hwdata1 = 32'b0; hwrite1 = 1'b0; htrans1 = 2'b00;

        // ------------------------------------------------------
        // TEST 0: RESET BEHAVIOUR
        // ------------------------------------------------------
        repeat (2) @(posedge clk);
        check_bit("RESET: hready0 low during reset",  1'b0, hready0);
        check_bit("RESET: hready1 low during reset",  1'b0, hready1);
        check_equal("RESET: gpio_out is 0 after reset", 32'h0, gpio_out);

        #20;
        rst = 1'b0;

        $display("========================================");
        $display("RESET RELEASED");
        $display("========================================");

        // ------------------------------------------------------
        // TEST 1: SHARED SRAM (normal access)
        // ------------------------------------------------------
        $display("---- TEST 1: SHARED SRAM ----");

        core0_write(32'h0000_0000, 32'h1234_5678);
        core0_read (32'h0000_0000, rdata, rerr);
        check_equal("T1: SRAM read-back data", 32'h1234_5678, rdata);
        check_bit  ("T1: SRAM read has no error", 1'b0, rerr);

        // second location, written by core1, read by core0
        // (proves the shared memory is truly shared between cores)
        core1_write(32'h0000_0010, 32'hCAFEF00D);
        core0_read (32'h0000_0010, rdata, rerr);
        check_equal("T1: SRAM shared across cores", 32'hCAFEF00D, rdata);

        // ------------------------------------------------------
        // TEST 2: MAILBOX (inter-core communication)
        // ------------------------------------------------------
        $display("---- TEST 2: MAILBOX ----");

        // Core0 -> Core1 message
        core0_write(32'h1000_0000, 32'hDEAD_BEEF);
        core1_read (32'h1000_0000, rdata, rerr);
        check_equal("T2: mailbox0->1 data", 32'hDEAD_BEEF, rdata);

        core1_read (32'h1000_0008, rdata, rerr);
        check_bit("T2: valid_0_to_1 flag set", 1'b1, rdata[0]);

        // Core1 clears the flag after reading its message
        core1_write(32'h1000_0008, 32'h0000_0001);
        core1_read (32'h1000_0008, rdata, rerr);
        check_bit("T2: valid_0_to_1 flag cleared", 1'b0, rdata[0]);

        // Core1 -> Core0 message
        core1_write(32'h1000_0004, 32'h0000_BEEF);
        core0_read (32'h1000_0004, rdata, rerr);
        check_equal("T2: mailbox1->0 data", 32'h0000_BEEF, rdata);

        // ------------------------------------------------------
        // TEST 3: GPIO
        // ------------------------------------------------------
        $display("---- TEST 3: GPIO ----");

        core0_write(32'h2000_0000, 32'h0000_00AA);
        @(posedge clk);
        check_equal("T3: gpio_out reflects write", 32'h0000_00AA, gpio_out);

        // ------------------------------------------------------
        // TEST 4: UART
        // ------------------------------------------------------
        $display("---- TEST 4: UART ----");

        core1_write(32'h3000_0000, 32'h0000_0048); // 'H'
        @(posedge clk);
        check_equal("T4: uart_tx_data value", 8'h48, uart_tx_data);
        check_bit  ("T4: uart_tx_valid pulses", 1'b1, uart_tx_valid);

        // ------------------------------------------------------
        // TEST 5: INVALID / UNMAPPED ADDRESS
        // ------------------------------------------------------
        $display("---- TEST 5: INVALID ADDRESS ----");

        core0_read(32'h4000_0000, rdata, rerr);
        check_bit("T5: invalid address flags hresp error", 1'b1, rerr);

        // ------------------------------------------------------
        // TEST 6: SIMULTANEOUS REQUESTS / ARBITRATION (contention)
        //
        // Both cores issue a request on the SAME clock edge to
        // two DIFFERENT slaves. The arbiter must serve them one
        // at a time (structural sharing of the single interconnect
        // pipeline), round-robin, with no data corruption on
        // either side.
        // ------------------------------------------------------
        $display("---- TEST 6: SIMULTANEOUS REQUESTS (CONTENTION) ----");

        @(posedge clk);
        // Core0 -> shared SRAM, Core1 -> GPIO, asserted the same cycle
        haddr0  = 32'h0000_0020; hwdata0 = 32'hAAAA_0000;
        hwrite0 = 1'b1;          htrans0 = 2'b10;

        haddr1  = 32'h2000_0000; hwdata1 = 32'h0000_0055;
        hwrite1 = 1'b1;          htrans1 = 2'b10;

        // Wait for BOTH to complete (arbiter must eventually grant both)
        fork
            begin : wait0
                wait (hready0 == 1'b1);
            end
            begin : wait1
                wait (hready1 == 1'b1);
            end
        join

        @(posedge clk);
        htrans0 = 2'b00; hwrite0 = 1'b0;
        htrans1 = 2'b00; hwrite1 = 1'b0;

        // Verify neither transaction corrupted the other
        core0_read(32'h0000_0020, rdata, rerr);
        check_equal("T6: core0 write not corrupted by contention", 32'hAAAA_0000, rdata);

        @(posedge clk);
        check_equal("T6: core1 GPIO write not corrupted by contention", 32'h0000_0055, gpio_out);

        // ------------------------------------------------------
        // TEST 7: BACK-TO-BACK ACCESSES (same master, no gap)
        // ------------------------------------------------------
        $display("---- TEST 7: BACK-TO-BACK ACCESSES ----");

        for (i = 0; i < 4; i = i + 1) begin
            core0_write(32'h0000_0030 + (i*4), 32'h1000_0000 + i);
        end

        for (i = 0; i < 4; i = i + 1) begin
            core0_read(32'h0000_0030 + (i*4), rdata, rerr);
            check_equal("T7: back-to-back SRAM word", 32'h1000_0000 + i, rdata);
        end

        // ------------------------------------------------------
        // FINAL SUMMARY
        // ------------------------------------------------------
        #30;
        $display("========================================");
        $display("NoC INTERCONNECT SELF-CHECKING TEST DONE");
        $display("TOTAL PASS = %0d", pass_count);
        $display("TOTAL FAIL = %0d", fail_count);
        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: **** %0d TEST(S) FAILED ****", fail_count);
        $display("========================================");

        $finish;
    end

endmodule
