`timescale 1ns/1ps

module tb_dual_core_soc;

reg clk;
reg reset;
reg uart_rx_line;
wire uart_tx_line;

dual_core_soc dut (
    .clk(clk),
    .reset(reset),
    .uart_tx_line(uart_tx_line),
    .uart_rx_line(uart_rx_line)
);

always #10 clk = ~clk;

initial begin
    clk = 1'b0;
    reset = 1'b1;
    uart_rx_line = 1'b1;
    $dumpfile("dual_core_soc.vcd");
    $dumpvars(0, tb_dual_core_soc);

    repeat (4) @(posedge clk);
    reset <= 1'b0;
    repeat (100) @(posedge clk);

    if (dut.system.shared_memory.memory[0] !== 32'd15) begin
        $display("FAIL: core 0 result is %h", dut.system.shared_memory.memory[0]);
        $finish;
    end

    if (dut.system.shared_memory.memory[1] !== 32'd3) begin
        $display("FAIL: core 1 result is %h", dut.system.shared_memory.memory[1]);
        $finish;
    end

    $display("PASS: both cores completed their programs");
    $display("shared_memory[0] = %0d", dut.system.shared_memory.memory[0]);
    $display("shared_memory[1] = %0d", dut.system.shared_memory.memory[1]);
    $finish;
end

endmodule

