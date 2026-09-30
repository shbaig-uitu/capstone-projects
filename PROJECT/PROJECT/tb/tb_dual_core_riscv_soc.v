`timescale 1ns/1ps

// ================================================================
// tb_dual_core_riscv_soc.v  -  STEP 3 (self-checking version)
//
// Full SoC-level test. Both RV32I cores run REAL machine-code
// programs (prog/core0.txt, prog/core1.txt) that were generated
// by prog/mini_rv32i_asm.py:
//
//   CORE0 : writes 0x55 into the mailbox (core0->core1),
//           then writes 0xAA to GPIO, then loops forever.
//
//   CORE1 : waits a few cycles, reads the mailbox message that
//           core0 sent, then echoes that exact value out on the
//           UART tx data register, then loops forever.
//
// This proves, end-to-end, on real fetched/decoded/executed
// instructions:
//   - both cores independently execute their own program
//   - shared-memory / mailbox based inter-core communication
//   - routing through the NoC-inspired interconnect to two
//     different peripherals (GPIO, UART)
//
// Self-checking: the final GPIO value and the UART byte that
// core1 transmits are compared against the values we know the
// programs must produce. Any mismatch is a REAL bug (this is
// exactly how the tb_noc_interconnect.v test caught the bad
// register reference in the original core1.txt).
// ================================================================

module tb_dual_core_riscv_soc;

    integer pass_count;
    integer fail_count;

    task automatic check_equal;
        input [255:0] test_name;
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

    // ============================================================
    // CLOCK AND RESET
    // ============================================================
    reg clk;
    reg rst;

    // ============================================================
    // OUTPUTS FROM DUT
    // ============================================================
    wire [31:0] gpio_out;
    wire [7:0]  uart_tx_data;
    wire        uart_tx_valid;

    // ============================================================
    // DUT
    // ============================================================
    dual_core_riscv_soc #(
        .CORE0_PROGRAM("core0.txt"),
        .CORE1_PROGRAM("core1.txt")
    ) dut (
        .clk(clk),
        .rst(rst),
        .gpio_out(gpio_out),
        .uart_tx_data(uart_tx_data),
        .uart_tx_valid(uart_tx_valid)
    );

    // ============================================================
    // CLOCK GENERATION
    // ============================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // CAPTURE THE UART BYTE CORE1 TRANSMITS
    // ============================================================
    reg [7:0] captured_uart_byte;
    reg       uart_seen;

    initial begin
        captured_uart_byte = 8'h00;
        uart_seen = 1'b0;
    end

    always @(posedge uart_tx_valid) begin
        if (!rst) begin
            captured_uart_byte = uart_tx_data;
            uart_seen = 1'b1;
            $display("TIME = %0t | UART TX CAPTURED | DATA = %h",
                      $time, uart_tx_data);
        end
    end

    // ============================================================
    // MONITOR GPIO (informational)
    // ============================================================
    always @(gpio_out) begin
        if (!rst) begin
            $display("TIME = %0t | GPIO = %h", $time, gpio_out);
        end
    end

    // ============================================================
    // MAIN SEQUENCE
    // ============================================================
    initial begin

        pass_count = 0;
        fail_count = 0;

        // ------------------------------------------------------
        // RESET TEST
        // ------------------------------------------------------
        rst = 1'b1;
        repeat (2) @(posedge clk);
        check_equal("RESET: gpio_out is 0 during reset", 32'h0, gpio_out);

        #20;
        rst = 1'b0;

        $display("========================================");
        $display("RESET RELEASED - DUAL CORE SOC STARTED");
        $display("========================================");

        // ------------------------------------------------------
        // Let both cores run their full programs.
        // Each program is only a handful of instructions, so
        // 500 ns (50 clock cycles) is generous headroom.
        // ------------------------------------------------------
        #500;

        // ------------------------------------------------------
        // CHECK 1: CORE0 -> GPIO
        // core0 must have written 0xAA to GPIO after sending
        // its mailbox message.
        // ------------------------------------------------------
        check_equal("CORE0 wrote expected value to GPIO",
                    32'h0000_00AA, gpio_out);

        // ------------------------------------------------------
        // CHECK 2: CORE0 -> MAILBOX -> CORE1 -> UART
        // core1 must have read the exact byte core0 sent through
        // the mailbox (0x55) and retransmitted it on UART.
        // ------------------------------------------------------
        check_equal("CORE1 transmitted the byte it read from the mailbox",
                    32'h0000_0055, {24'h0, captured_uart_byte});

        check_equal("UART transmit event actually happened",
                    32'h1, {31'h0, uart_seen});

        // ------------------------------------------------------
        // FINAL SUMMARY
        // ------------------------------------------------------
        $display("========================================");
        $display("DUAL CORE SOC SELF-CHECKING TEST DONE");
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
