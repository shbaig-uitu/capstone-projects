`timescale 1ns / 1ps
module soc_tb;

    logic clk;
    logic reset;

    wire [31:0] imem_addr;
    wire [31:0] imem_data;

    soc_top uut (
        .clk       (clk),
        .reset     (reset),
        .imem_addr (imem_addr),
        .imem_data (imem_data)
    );

    instruction_memory imem_u (
        .pc   (imem_addr),
        .inst (imem_data)
    );

    always #5 clk = ~clk;

    // Diagnostic Monitor for Bus Activity
    always @(posedge clk) begin
        if (uut.accelerator_u.AWVALID && uut.accelerator_u.AWREADY) begin
            $display("[AXI WRITE] Time=%0t | Offset=0x%02h | WDATA=0x%08h", 
                     $time, uut.accelerator_u.AWADDR[7:0], uut.accelerator_u.WDATA);
        end
        if (uut.accelerator_u.start_pulse) begin
            $display(">>> [START PULSE TRIGGERED] Time=%0t | Computing A x B... <<<", $time);
        end
    end

    initial begin
        clk   = 0;
        reset = 0;
        #20;
        reset = 1;

        $display("=================================================");
        $display("STARTING FULL SOC + 4x4 SYSTOLIC ACCELERATOR TEST");
        $display("=================================================");

        // Wait for execution and systolic array calculation
        #3500;

        $display("\n================ MATRIX A (INPUT) ================");
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.mat_a_reg[0][7:0],   uut.accelerator_u.mat_a_reg[0][15:8],  uut.accelerator_u.mat_a_reg[0][23:16],  uut.accelerator_u.mat_a_reg[0][31:24]);
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.mat_a_reg[1][7:0],   uut.accelerator_u.mat_a_reg[1][15:8],  uut.accelerator_u.mat_a_reg[1][23:16],  uut.accelerator_u.mat_a_reg[1][31:24]);
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.mat_a_reg[2][7:0],   uut.accelerator_u.mat_a_reg[2][15:8],  uut.accelerator_u.mat_a_reg[2][23:16],  uut.accelerator_u.mat_a_reg[2][31:24]);
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.mat_a_reg[3][7:0],   uut.accelerator_u.mat_a_reg[3][15:8],  uut.accelerator_u.mat_a_reg[3][23:16],  uut.accelerator_u.mat_a_reg[3][31:24]);

        $display("\n================ MATRIX B (INPUT) ================");
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.mat_b_reg[0][7:0],   uut.accelerator_u.mat_b_reg[1][7:0],   uut.accelerator_u.mat_b_reg[2][7:0],    uut.accelerator_u.mat_b_reg[3][7:0]);
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.mat_b_reg[0][15:8],  uut.accelerator_u.mat_b_reg[1][15:8],  uut.accelerator_u.mat_b_reg[2][15:8],   uut.accelerator_u.mat_b_reg[3][15:8]);
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.mat_b_reg[0][23:16], uut.accelerator_u.mat_b_reg[1][23:16], uut.accelerator_u.mat_b_reg[2][23:16],  uut.accelerator_u.mat_b_reg[3][23:16]);
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.mat_b_reg[0][31:24], uut.accelerator_u.mat_b_reg[1][31:24], uut.accelerator_u.mat_b_reg[2][31:24],  uut.accelerator_u.mat_b_reg[3][31:24]);

        $display("\n========== COMPUTED MATRIX C (OUTPUT: A x B) ==========");
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.c_out[0][0], uut.accelerator_u.c_out[0][1], uut.accelerator_u.c_out[0][2], uut.accelerator_u.c_out[0][3]);
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.c_out[1][0], uut.accelerator_u.c_out[1][1], uut.accelerator_u.c_out[1][2], uut.accelerator_u.c_out[1][3]);
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.c_out[2][0], uut.accelerator_u.c_out[2][1], uut.accelerator_u.c_out[2][2], uut.accelerator_u.c_out[2][3]);
        $display("[%0d, %0d, %0d, %0d]", uut.accelerator_u.c_out[3][0], uut.accelerator_u.c_out[3][1], uut.accelerator_u.c_out[3][2], uut.accelerator_u.c_out[3][3]);

        $display("\n--- RISC-V CORE REGISTERS ---");
        $display("x1 (Base) = 0x%08h", uut.core_u.rf_u.registers[1]);
        $display("x8 (C33)  = %0d", uut.core_u.rf_u.registers[8]);
        $display("=================================================\n");

        $finish;
    end

endmodule
