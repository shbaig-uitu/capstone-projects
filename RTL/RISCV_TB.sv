`timescale 1ns / 1ps

module riscv_tb;
    logic clk;
    logic reset;

    wire [31:0] imem_addr;
    wire [31:0] imem_data;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire        mem_read;
    wire        mem_write;
    reg  [31:0] mem_rdata;

    reg [31:0] dmem [0:255];
    integer errors = 0;

    riscv_top uut (
        .clk        (clk),
        .reset      (reset),
        .imem_addr  (imem_addr),
        .imem_data  (imem_data),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_rdata  (mem_rdata)
    );

    instruction_memory imem_u (
        .pc   (imem_addr),
        .inst (imem_data)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (mem_write)
            dmem[mem_addr[9:2]] <= mem_wdata;
    end

    always @(*) begin
        if (mem_read)
            mem_rdata = dmem[mem_addr[9:2]];
        else
            mem_rdata = 32'b0;
    end

    initial begin
        clk = 0;
        reset = 0;
        #20;
        reset = 1;

        $display("=================================================");
        $display("Starting Comprehensive RISC-V Verification Suite");
        $display("=================================================");

        // Wait for instructions to complete execution
        #240;

        // Check 1: Register x0 must NEVER change
        if (uut.rf_u.registers[0] !== 32'd0) begin
            $error("[FAIL] x0 register is not zero! Got: %0d", uut.rf_u.registers[0]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x0 Hardwire-to-Zero check passed.");
        end

        // Check 2: Logic Operations (OR, XOR, AND)
        if (uut.rf_u.registers[4] !== 32'd768 || uut.rf_u.registers[5] !== 32'd768 || uut.rf_u.registers[6] !== 32'd0) begin
            $error("[FAIL] Bitwise Logic check failed! x4=%0d, x5=%0d, x6=%0d", 
                   uut.rf_u.registers[4], uut.rf_u.registers[5], uut.rf_u.registers[6]);
            errors = errors + 1;
        end else begin
            $display("[PASS] Bitwise Operations (OR, XOR, AND) passed.");
        end

        // Check 3: Subtraction
        if (uut.rf_u.registers[7] !== 32'd256) begin
            $error("[FAIL] SUB operation failed! x7=%0d (Expected 256)", uut.rf_u.registers[7]);
            errors = errors + 1;
        end else begin
            $display("[PASS] Subtraction (SUB) passed.");
        end

        // Check 4: Shifts (Logical vs Arithmetic)
        if (uut.rf_u.registers[10] !== 32'h3FFFFFFC || uut.rf_u.registers[11] !== 32'hFFFFFFFC) begin
            $error("[FAIL] Shift Operations failed! SRLI(x10)=0x%08h, SRAI(x11)=0x%08h", 
                   uut.rf_u.registers[10], uut.rf_u.registers[11]);
            errors = errors + 1;
        end else begin
            $display("[PASS] Shift operations (SRLI, SRAI) sign-extension passed.");
        end

        // Check 5: Signed vs Unsigned Comparison
        if (uut.rf_u.registers[12] !== 32'd1 || uut.rf_u.registers[13] !== 32'd0) begin
            $error("[FAIL] Comparison failed! SLTI(x12)=%0d, SLTIU(x13)=%0d", 
                   uut.rf_u.registers[12], uut.rf_u.registers[13]);
            errors = errors + 1;
        end else begin
            $display("[PASS] SLTI (Signed) vs SLTIU (Unsigned) comparison passed.");
        end

        // Check 6: LUI (Load Upper Immediate)
        if (uut.rf_u.registers[14] !== 32'h12345000) begin
            $error("[FAIL] LUI failed! x14=0x%08h (Expected 0x12345000)", uut.rf_u.registers[14]);
            errors = errors + 1;
        end else begin
            $display("[PASS] LUI instruction passed.");
        end

        // Check 7: JAL Jump Test
        if (uut.rf_u.registers[16] !== 32'd0 || uut.rf_u.registers[17] !== 32'd1) begin
            $error("[FAIL] JAL jump failed! x16 trap was hit or x17 was not reached.");
            errors = errors + 1;
        end else begin
            $display("[PASS] JAL unconditional jump sequence passed.");
        end

        $display("=================================================");
        if (errors == 0) begin
            $display(">> ALL 7 ADVANCED CHECKS PASSED! CORE IS ROBUST. <<");
        end else begin
            $display(">> %0d ERRORS FOUND. FIX REQUIRED. <<", errors);
        end
        $display("=================================================");

        $finish;
    end

endmodule
