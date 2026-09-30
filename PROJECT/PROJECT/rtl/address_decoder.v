`timescale 1ns/1ps

module address_decoder (

    input wire [31:0] addr,

    // Slave select signals
    output reg sel_shared_ram,
    output reg sel_mailbox,
    output reg sel_gpio,
    output reg sel_uart,

    // Invalid / unmapped address
    output reg sel_error

);

    always @(*) begin

        // Default: nothing selected
        sel_shared_ram = 1'b0;
        sel_mailbox    = 1'b0;
        sel_gpio       = 1'b0;
        sel_uart       = 1'b0;
        sel_error      = 1'b0;

        // =====================================================
        // SHARED SRAM
        //
        // Address Range:
        // 0x0000_0000 - 0x0000_FFFF
        // =====================================================
        if (addr >= 32'h0000_0000 &&
            addr <= 32'h0000_FFFF) begin

            sel_shared_ram = 1'b1;

        end

        // =====================================================
        // MAILBOX
        //
        // Address Range:
        // 0x1000_0000 - 0x1000_00FF
        // =====================================================
        else if (addr >= 32'h1000_0000 &&
                 addr <= 32'h1000_00FF) begin

            sel_mailbox = 1'b1;

        end

        // =====================================================
        // GPIO
        //
        // Address Range:
        // 0x2000_0000 - 0x2000_00FF
        // =====================================================
        else if (addr >= 32'h2000_0000 &&
                 addr <= 32'h2000_00FF) begin

            sel_gpio = 1'b1;

        end

        // =====================================================
        // UART
        //
        // Address Range:
        // 0x3000_0000 - 0x3000_00FF
        // =====================================================
        else if (addr >= 32'h3000_0000 &&
                 addr <= 32'h3000_00FF) begin

            sel_uart = 1'b1;

        end

        // =====================================================
        // INVALID / UNMAPPED ADDRESS
        // =====================================================
        else begin

            sel_error = 1'b1;

        end

    end

endmodule
