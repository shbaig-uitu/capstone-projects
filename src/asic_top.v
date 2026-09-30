// asic_top.v (Fixed)
module asic_top (
    input  wire clk,        // Pure clock from pad
    input  wire rst_n,      // Active-low reset from pad
    output wire uart_tx    // UART TX pad
);

    // Invert active-low reset for internal active-high modules
    wire internal_rst = ~rst_n;

    soc_top soc_inst (
        .clk(clk),
        .rst(internal_rst),
        .uart_tx_pin(uart_tx)
    );

endmodule
