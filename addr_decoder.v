`include "rv32i_soc_defines.v"

module addr_decoder (
    input  wire [31:0] haddr,
    output reg  [2:0]  slave_sel,
    output wire         addr_valid
);

    always @(*) begin
        if ((haddr >= `DMEM_BASE) && (haddr <= `DMEM_END)) begin
            slave_sel = `SLAVE_DMEM;
        end else if ((haddr >= `MAILBOX_BASE) && (haddr <= `MAILBOX_END)) begin
            slave_sel = `SLAVE_MAILBOX;
        end else if ((haddr >= `UART_BASE) && (haddr <= `UART_END)) begin
            slave_sel = `SLAVE_UART;
        end else if ((haddr >= `GPIO_BASE) && (haddr <= `GPIO_END)) begin
            slave_sel = `SLAVE_GPIO;
        end else begin
            slave_sel = `SLAVE_NONE;
        end
    end

    assign addr_valid = (slave_sel != `SLAVE_NONE);

endmodule
