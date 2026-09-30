`timescale 1ns / 1ps

module pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                   clk,
    input  wire                   rst_n,      // Active-low reset
    input  wire                   clr_acc,    // Clear accumulator for new matrix
    input  wire                   en,         // Enable computation & shift
    input  wire [DATA_WIDTH-1:0]  a_in,       // From Left PE / Buffer
    input  wire [DATA_WIDTH-1:0]  b_in,       // From Top PE / Buffer
    output reg  [DATA_WIDTH-1:0]  a_out,      // To Right PE
    output reg  [DATA_WIDTH-1:0]  b_out,      // To Bottom PE
    output reg  [ACC_WIDTH-1:0]   acc_out     // Accumulated Result C[i][j]
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out   <= {DATA_WIDTH{1'b0}};
            b_out   <= {DATA_WIDTH{1'b0}};
            acc_out <= {ACC_WIDTH{1'b0}};
        end else if (clr_acc) begin
            a_out   <= {DATA_WIDTH{1'b0}};
            b_out   <= {DATA_WIDTH{1'b0}};
            acc_out <= {ACC_WIDTH{1'b0}};
        end else if (en) begin
            // Forward inputs across the grid
            a_out   <= a_in;
            b_out   <= b_in;
            // Multiply and Accumulate
            acc_out <= acc_out + (a_in * b_in);
        end
    end

endmodule
