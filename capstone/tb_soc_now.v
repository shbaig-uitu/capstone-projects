`timescale 1ns/1ps

module tb_soc_top;
    reg clk = 0;
    reg rst = 1;

    // 100 MHz clock
    always #5 clk = ~clk;

    // Instantiate the SoC
    soc_top dut (
        .clk(clk),
        .rst(rst)
    );

    // Track previous state to detect rising edges
    reg prev_accel_done = 0;
    reg prev_accel_start = 0;

// Monitor AXI Bus and Accelerator Events
    always @(posedge clk) begin
        if (!rst) begin
            // 1. Monitor AXI Address Write
            if (dut.bridge.awvalid && dut.bridge.awready) begin
                $display("[%0t ns] CPU WRITE -> Addr: 0x%08h", $time, dut.bridge.awaddr);
            end
            
            // 2. Monitor AXI Data Write
            if (dut.bridge.wvalid && dut.bridge.wready) begin
                $display("[%0t ns] CPU WRITE -> Data: 0x%08h", $time, dut.bridge.wdata);
            end
            
            // 3. Monitor AXI Reads
            if (dut.bridge.rvalid && dut.bridge.rready) begin
                $display("[%0t ns] CPU READ  <- Addr: 0x%08h | Data: 0x%08h", 
                         $time, dut.bridge.araddr, dut.bridge.rdata);
            end

            // 4. Monitor Accelerator Start & Done
            prev_accel_start <= dut.accel.start;
            if (dut.accel.start && !prev_accel_start) begin
                $display("[%0t ns] *** ACCELERATOR STARTED: Computing 4x4 Matrix Multiplication ***", $time);
            end

            prev_accel_done <= dut.accel.done;
            if (dut.accel.done && !prev_accel_done) begin
                $display("[%0t ns] *** ACCELERATOR DONE: Matrix Math Complete ***", $time);
            end
        end
    end

    integer i;

    initial begin
        // Load the Matrix Multiplication program
        $readmemh("matmul.hex", dut.cpu.imem0.mem);
        
        // Setup Waveform dumping
        $dumpfile("tb_soc_top.vcd");
        $dumpvars(0, tb_soc_top);

        $display("==================================================");
        $display(" Starting RISC-V SoC Matrix Multiplication Test   ");
        $display("==================================================");

        // Apply Reset
        repeat(5) @(posedge clk);
        rst = 0;

        // Run simulation for enough cycles to load, multiply, and read back
        repeat(500) @(posedge clk);
        
        $display("\n==================================================");
        $display(" Simulation Finished. Dumping Final State:");
        $display("==================================================");
        
        // Print key CPU Registers
        $display("--- CPU Register File ---");
        $display(" x1 (Base Addr) : 0x%08h", dut.cpu.rf.regs[1]);
        $display(" x2 (Weight)    : %0d", dut.cpu.rf.regs[2]);
        $display(" x3 (Activation): %0d", dut.cpu.rf.regs[3]);
        $display(" x4 (Status Reg): %0d", dut.cpu.rf.regs[4]);
        $display(" x6 (Result[0]) : %0d  <-- Should be 2 (1 * 2)", dut.cpu.rf.regs[6]);

        // Print Accelerator Result Buffer as a 4x4 Matrix
        $display("\n--- Accelerator Hardware Result Matrix (C = A x B) ---");
        for (i = 0; i < 4; i = i + 1) begin
            $display(" [ %4d %4d %4d %4d ]", 
                $signed(dut.accel.result_buf[i*4+0]), $signed(dut.accel.result_buf[i*4+1]), 
                $signed(dut.accel.result_buf[i*4+2]), $signed(dut.accel.result_buf[i*4+3]));
        end
        $display("==================================================\n");

        $finish;
    end
endmodule