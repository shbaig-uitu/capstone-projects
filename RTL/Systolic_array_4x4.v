`timescale 1ns / 1ps

module systolic_array_4x4 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   clr_acc,
    input  wire                   en,

    // Matrix A Inputs (Row 0 to 3)
    input  wire [DATA_WIDTH-1:0]  a_in_0,
    input  wire [DATA_WIDTH-1:0]  a_in_1,
    input  wire [DATA_WIDTH-1:0]  a_in_2,
    input  wire [DATA_WIDTH-1:0]  a_in_3,

    // Matrix B Inputs (Col 0 to 3)
    input  wire [DATA_WIDTH-1:0]  b_in_0,
    input  wire [DATA_WIDTH-1:0]  b_in_1,
    input  wire [DATA_WIDTH-1:0]  b_in_2,
    input  wire [DATA_WIDTH-1:0]  b_in_3,

    // 16 Accumulator Outputs
    output wire [ACC_WIDTH-1:0]   c_00, c_01, c_02, c_03,
    output wire [ACC_WIDTH-1:0]   c_10, c_11, c_12, c_13,
    output wire [ACC_WIDTH-1:0]   c_20, c_21, c_22, c_23,
    output wire [ACC_WIDTH-1:0]   c_30, c_31, c_32, c_33
);

    // Internal routing wires between PEs
    wire [DATA_WIDTH-1:0] a_h [0:3][0:4];
    wire [DATA_WIDTH-1:0] b_v [0:4][0:3];
    wire [ACC_WIDTH-1:0]  acc [0:3][0:3];

    // External inputs drive boundary [0]
    assign a_h[0][0] = a_in_0;
    assign a_h[1][0] = a_in_1;
    assign a_h[2][0] = a_in_2;
    assign a_h[3][0] = a_in_3;

    assign b_v[0][0] = b_in_0;
    assign b_v[0][1] = b_in_1;
    assign b_v[0][2] = b_in_2;
    assign b_v[0][3] = b_in_3;

    // 4x4 Grid of PEs
    genvar r, c;
    generate
        for (r = 0; r < 4; r = r + 1) begin : row_gen
            for (c = 0; c < 4; c = c + 1) begin : col_gen
                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH(ACC_WIDTH)
                ) pe_inst (
                    .clk     (clk),
                    .rst_n   (rst_n),
                    .clr_acc (clr_acc),
                    .en      (en),
                    .a_in    (a_h[r][c]),
                    .b_in    (b_v[r][c]),
                    .a_out   (a_h[r][c+1]),
                    .b_out   (b_v[r+1][c]),
                    .acc_out (acc[r][c])
                );
            end
        end
    endgenerate

    // Output Mapping
    assign c_00 = acc[0][0]; assign c_01 = acc[0][1]; assign c_02 = acc[0][2]; assign c_03 = acc[0][3];
    assign c_10 = acc[1][0]; assign c_11 = acc[1][1]; assign c_12 = acc[1][2]; assign c_13 = acc[1][3];
    assign c_20 = acc[2][0]; assign c_21 = acc[2][1]; assign c_22 = acc[2][2]; assign c_23 = acc[2][3];
    assign c_30 = acc[3][0]; assign c_31 = acc[3][1]; assign c_32 = acc[3][2]; assign c_33 = acc[3][3];

endmodule
