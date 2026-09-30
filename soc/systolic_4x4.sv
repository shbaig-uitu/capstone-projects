// systolic_4x4.sv - 4x4 Weight-Stationary Systolic Array
module systolic_4x4 #(parameter DW=8, AW=32, N=4)(
  input  wire                     clk, rst_n,
  input  wire                     load_weight,
  input  wire signed [N*N*DW-1:0] weights,   // flattened 16 weights (4x4)
  input  wire signed [N*DW-1:0]   act_in,    // flattened 4 activations
  output wire signed [N*AW-1:0]   psum_out   // flattened 4 partial sum columns
);

  // Internal wires: act[row][col], psum[row+1][col]
  wire signed [DW-1:0] act  [0:N-1][0:N];
  wire signed [AW-1:0] psum [0:N][0:N-1];

  genvar i, j;
  generate
    for (i = 0; i < N; i = i + 1) begin : row
      assign act[i][0] = act_in[i*DW +: DW]; // connect inputs to left edge
      assign psum[0][i] = 0;                 // top row gets zero psum

      for (j = 0; j < N; j = j + 1) begin : col
        pe #(.DW(DW),.AW(AW)) u_pe (
          .clk        (clk),
          .rst_n      (rst_n),
          .load_weight(load_weight),
          .weight_in  (weights[(i*N + j)*DW +: DW]),
          .act_in     (act[i][j]),
          .psum_in    (psum[i][j]),
          .act_out    (act[i][j+1]),     // pass right
          .psum_out   (psum[i+1][j])     // pass down
        );
      end
    end
  endgenerate

  // Bottom row outputs = complete dot products
  genvar k;
  generate
    for (k = 0; k < N; k = k + 1) begin : out_col
      assign psum_out[k*AW +: AW] = psum[N][k];
    end
  endgenerate

endmodule
