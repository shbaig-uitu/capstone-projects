interface core_if_uvm(
    input logic clk,
    input logic reset
);

    logic        read;
    logic        write;
    logic [31:0] address;
    logic [31:0] write_data;

    logic [31:0] read_data;
    logic        ready;

endinterface