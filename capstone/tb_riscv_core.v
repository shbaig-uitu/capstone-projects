// tb_soc_top.v
// Testbench for the complete single-cycle RV32I SoC
// Loads program.hex, runs for 50 cycles,
// checks that DMEM address 0 contains 15.

`timescale 1ns/1ps

module tb_soc_top;

    // ------------------------------------------------------------
    // Clock and Reset
    // ------------------------------------------------------------
    reg clk = 1'b0;
    reg rst = 1'b1;

    // 100 MHz clock
    always #5 clk = ~clk;


    // ------------------------------------------------------------
    // Instantiate SoC
    // ------------------------------------------------------------
    soc_top dut (
        .clk(clk),
        .rst(rst)
    );


    // ------------------------------------------------------------
    // Test variables
    // ------------------------------------------------------------
    integer i;
    reg [31:0] result;


    // ------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------
    initial begin

        // --------------------------------------------------------
        // Load program into instruction memory
        // --------------------------------------------------------
        $readmemh("program.hex", dut.cpu.imem0.mem);


        // --------------------------------------------------------
        // Initialize data memory to zero
        // --------------------------------------------------------
        for (i = 0; i < 256; i = i + 1)
            dut.dmem0.mem[i] = 8'h00;


        // --------------------------------------------------------
        // Waveform dump
        // --------------------------------------------------------
        $dumpfile("tb_soc_top.vcd");
        $dumpvars(0, tb_soc_top);


        // --------------------------------------------------------
        // Hold reset for 2 clock cycles
        // --------------------------------------------------------
        repeat (2) @(posedge clk);
        rst = 1'b0;


        // --------------------------------------------------------
        // Run processor for 50 cycles
        // --------------------------------------------------------
        repeat (50) @(posedge clk);

        // Allow memory writes/signals to settle
        #1;


        // --------------------------------------------------------
        // Read 32-bit value from DMEM address 0
        //
        // DMEM is byte-addressed and little-endian:
        //
        // mem[0] = bits [7:0]
        // mem[1] = bits [15:8]
        // mem[2] = bits [23:16]
        // mem[3] = bits [31:24]
        // --------------------------------------------------------
        result = {dut.dmem0.mem[3],
                  dut.dmem0.mem[2],
                  dut.dmem0.mem[1],
                  dut.dmem0.mem[0]};


        // --------------------------------------------------------
        // Check result
        // --------------------------------------------------------
        if (result === 32'd15)
            $display("PASS: sum(1..5) = %0d stored at mem[0]", result);
        else
            $display("FAIL: mem[0] = %0d (expected 15)", result);


        // --------------------------------------------------------
        // Register file snapshot
        // --------------------------------------------------------
        $display("");
        $display("--- Register File Snapshot ---");

        for (i = 0; i < 8; i = i + 1)
            $display("  x%0d = %0d", i, dut.cpu.rf.regs[i]);


        // --------------------------------------------------------
        // Optional CPU state
        // --------------------------------------------------------
        $display("");
        $display("--- CPU State ---");
        $display("PC = 0x%08h", dut.cpu.pc);


        // --------------------------------------------------------
        // Finish
        // --------------------------------------------------------
        $finish;

    end

endmodule

