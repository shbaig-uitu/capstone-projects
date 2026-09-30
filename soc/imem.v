// imem.v - Hardware Mask ROM with Self-Checking Systolic Array MatMul
`default_nettype none

module imem (
    input  wire [31:0] addr,
    output reg  [31:0] instr
);
    wire [29:0] word_idx = addr[31:2];

    always @(*) begin
        case (word_idx)
            // 1. Initialize addresses
            0:  instr = 32'h400000b7; // lui  x1, 0x40000       ; x1 = 0x40000000 (Accelerator base)
            1:  instr = 32'h00100113; // addi x2, x0, 1         ; x2 = val = 1
            2:  instr = 32'h04008193; // addi x3, x1, 0x40      ; x3 = 0x40000040 (Weight buffer start)
            3:  instr = 32'h0c008213; // addi x4, x1, 0xc0      ; x4 = 0x400000c0 (Limit: 32 words)

            // 2. Load Weights (1..16) and Activations (17..32) into Accelerator buffers
            4:  instr = 32'h0021a023; // sw   x2, 0(x3)         ; mem[x3] = val
            5:  instr = 32'h00110113; // addi x2, x2, 1         ; val++
            6:  instr = 32'h00418193; // addi x3, x3, 4         ; x3 += 4
            7:  instr = 32'hfe41cae3; // blt  x3, x4, -12       ; loop back to Word 4 until all 32 words written

            // 3. Status: Write 1 (Data Loaded) to LED MMIO (0x10000000)
            8:  instr = 32'h100004b7; // lui  x9, 0x10000       ; x9 = 0x10000000 (LED MMIO address)
            9:  instr = 32'h00100513; // addi x10, x0, 1        ; x10 = 1 (LED 0 ON)
            10: instr = 32'h00a4a023; // sw   x10, 0(x9)        ; write to LEDs

            // 4. Start Accelerator
            11: instr = 32'h00100293; // addi x5, x0, 1         ; x5 = 1 (start bit)
            12: instr = 32'h0050a023; // sw   x5, 0(x1)         ; ACCEL_CTRL = 1

            // 5. Status: Write 2 (Computing) to LED MMIO
            13: instr = 32'h00200513; // addi x10, x0, 2        ; x10 = 2 (LED 1 ON)
            14: instr = 32'h00a4a023; // sw   x10, 0(x9)        ; write to LEDs

            // 6. Poll DONE bit (bit 1 of 0x40000004)
            15: instr = 32'h0040a283; // lw   x5, 4(x1)          ; x5 = ACCEL_STATUS
            16: instr = 32'h0022f313; // andi x6, x5, 2         ; x6 = status & 2
            17: instr = 32'hfe030ce3; // beq  x6, x0, -8        ; if done == 0, keep polling Word 15

            // 7. Read Result C[0][0] from 0x400000C0
            18: instr = 32'h0c008193; // addi x3, x1, 0xc0      ; x3 = 0x400000C0 (Result buffer)
            19: instr = 32'h0001a383; // lw   x7, 0(x3)         ; x7 = C[0][0]

            // 8. Verify Expected Value (538 = 0x21A)
            20: instr = 32'h21a00413; // addi x8, x0, 538       ; x8 = expected = 538
            21: instr = 32'h00839863; // bne  x7, x8, 16        ; if C[0][0] != 538 -> jump to FAIL (Word 25)

            // 9. PASS: Set LEDs to 0x0F (All 4 LEDs ON!)
            22: instr = 32'h00f00513; // addi x10, x0, 15       ; x10 = 15 (0x0F)
            23: instr = 32'h00a4a023; // sw   x10, 0(x9)        ; write 0x0F to LEDs
            24: instr = 32'h00c0006f; // jal  x0, 12            ; jump to HALT (Word 27)

            // 10. FAIL: Set LEDs to 0x05 (Alternating LEDs)
            25: instr = 32'h00500513; // addi x10, x0, 5        ; x10 = 5 (FAIL code)
            26: instr = 32'h00a4a023; // sw   x10, 0(x9)        ; write 0x05 to LEDs

            // 11. Halt Loop
            27: instr = 32'h0000006f; // jal  x0, 0             ; Halt
            default: instr = 32'h0000006f;
        endcase
    end
endmodule
`default_nettype wire
