// systolic_4x4.sv (ASIC Flattened Version)
module systolic_4x4 #(parameter DW=8, AW=32, N=4)(
  input  wire              clk, rst_n,
  input  wire              load_weight,
  input  wire [N*N*DW-1:0] weights_flat,  // FLATTENED: 128-bit wire
  input  wire [N*DW-1:0]   act_in_flat,   // FLATTENED: 32-bit wire
  output wire [N*AW-1:0]   psum_out_flat  // FLATTENED: 128-bit wire
);

  // Re-create the 2D arrays internally
  wire signed [DW-1:0] weights [0:N-1][0:N-1];
  wire signed [DW-1:0] act_in  [0:N-1];
  wire signed [AW-1:0] psum_out[0:N-1];

  // Unpack flat vectors into the 2D arrays
  genvar r, c;
  generate
    for (r = 0; r < N; r = r + 1) begin : unpack_r
      assign act_in[r] = act_in_flat[r*DW +: DW];
      assign psum_out_flat[r*AW +: AW] = psum_out[r];
      for (c = 0; c < N; c = c + 1) begin : unpack_c
        assign weights[r][c] = weights_flat[(r*N+c)*DW +: DW];
      end
    end
  endgenerate

  // Internal wires: act[row][col], psum[row+1][col]
  wire signed [DW-1:0] act  [0:N-1][0:N];
  wire signed [AW-1:0] psum [0:N][0:N-1];

  genvar i, j;
  generate
    for (i = 0; i < N; i++) begin : row
      assign act[i][0] = act_in[i];      // connect inputs to left edge
      assign psum[0][i] = 0;             // top row gets zero psum

      for (j = 0; j < N; j++) begin : col
        pe #(.DW(DW),.AW(AW)) u_pe (
          .clk        (clk),
          .rst_n      (rst_n),
          .load_weight(load_weight),
          .weight_in  (weights[i][j]),
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
    for (k = 0; k < N; k++) assign psum_out[k] = psum[N][k];
  endgenerate

endmodule
