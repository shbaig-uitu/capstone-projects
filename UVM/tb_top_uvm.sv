`timescale 1ns/1ps

import uvm_pkg::*;
import soc_uvm_pkg::*;

module tb_top_uvm;

    logic clk;
    logic reset;

    logic uart_tx_line;
    logic uart_rx_line;

    // Interfaces
    core_if_uvm core0_if(clk, reset);
    core_if_uvm core1_if(clk, reset);


    // DUT
    mailbox_system dut (
        .clk              (clk),
        .reset            (reset),

        .core0_read       (core0_if.read),
        .core0_write      (core0_if.write),
        .core0_address    (core0_if.address),
        .core0_write_data (core0_if.write_data),
        .core0_read_data  (core0_if.read_data),
        .core0_ready      (core0_if.ready),

        .core1_read       (core1_if.read),
        .core1_write      (core1_if.write),
        .core1_address    (core1_if.address),
        .core1_write_data (core1_if.write_data),
        .core1_read_data  (core1_if.read_data),
        .core1_ready      (core1_if.ready),

        .uart_tx_line     (uart_tx_line),
        .uart_rx_line     (uart_rx_line)
    );


    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // Reset generation
    initial begin
        reset        = 1;
        uart_rx_line = 1;

        repeat (5) @(posedge clk);

        reset = 0;
    end


    // UVM start
    initial begin

        uvm_config_db#(virtual core_if_uvm)::set(
            null,
            "uvm_test_top.env.core0_agent.*",
            "vif",
            core0_if
        );

        uvm_config_db#(virtual core_if_uvm)::set(
            null,
            "uvm_test_top.env.core1_agent.*",
            "vif",
            core1_if
        );

        // run_test MUST start at time 0
        run_test("full_system_test_uvm");

    end

endmodule