// FPGA top-level for Arty A7-100T.
// The wrapper:
//   1) accepts the board 100 MHz clock and active-low reset,
//   2) programs VPN 0 -> PPN 3 through the existing AXI register interface,
//   3) releases the RV32I core,
//   4) exposes MMU status on LEDs and UART.
//
// The existing SoC remains the actual design under test.

module fpga_top (
  input  logic clk,
  input  logic reset_n,

  output logic led_fault,
  output logic led_hit,
  output logic led_miss,
  output logic led_boot,
  output logic uart_txd
);

  // AXI-Lite signals driven by the small FPGA boot sequencer.
  logic [7:0]  awaddr;
  logic        awvalid;
  logic        awready;
  logic [31:0] wdata;
  logic        wvalid;
  logic        wready;
  logic [1:0]  bresp;
  logic        bvalid;
  logic        bready;

  logic [7:0]  araddr;
  logic        arvalid;
  logic        arready;
  logic [31:0] rdata;
  logic [1:0]  rresp;
  logic        rvalid;
  logic        rready;

  logic core_rst_n;

  typedef enum logic [1:0] {
    BOOT_WRITE,
    WAIT_RESPONSE,
    RUN
  } boot_state_t;

  boot_state_t state;

  // Register 0x00:
  //   bit 0    = valid
  //   bits 4:1 = PPN = 3
  //   bits 9:5 = VPN = 0
  // Therefore: 1 | (3 << 1) = 32'h0000_0007.
  localparam logic [31:0] PAGE_TABLE_ENTRY = 32'h0000_0007;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      state <= BOOT_WRITE;
    end else begin
      case (state)
        BOOT_WRITE: begin
          if (awvalid && awready && wvalid && wready)
            state <= WAIT_RESPONSE;
        end

        WAIT_RESPONSE: begin
          if (bvalid && bready)
            state <= RUN;
        end

        RUN: state <= RUN;

        default: state <= BOOT_WRITE;
      endcase
    end
  end

  assign awaddr  = 8'h00;
  assign awvalid = (state == BOOT_WRITE);

  assign wdata   = PAGE_TABLE_ENTRY;
  assign wvalid  = (state == BOOT_WRITE);

  assign bready  = 1'b1;

  // No AXI reads are needed for the standalone FPGA demo.
  assign araddr  = 8'h00;
  assign arvalid = 1'b0;
  assign rready  = 1'b1;

  assign core_rst_n = (state == RUN);
  assign led_boot   = (state == RUN);

  soc_top #(
    .CLK_FREQ_HZ        (100_000_000),
    .UART_BAUD          (115_200),
    .DEBUG_STRETCH_BITS (24),
    .IMEM_INIT_FILE     ("test_prog.hex")
  ) u_soc (
    .clk           (clk),
    .rst_n         (reset_n),
    .core_rst_n    (core_rst_n),

    .s_axi_awaddr  (awaddr),
    .s_axi_awvalid (awvalid),
    .s_axi_awready (awready),
    .s_axi_wdata   (wdata),
    .s_axi_wvalid  (wvalid),
    .s_axi_wready  (wready),
    .s_axi_bresp   (bresp),
    .s_axi_bvalid  (bvalid),
    .s_axi_bready  (bready),

    .s_axi_araddr  (araddr),
    .s_axi_arvalid (arvalid),
    .s_axi_arready (arready),
    .s_axi_rdata   (rdata),
    .s_axi_rresp   (rresp),
    .s_axi_rvalid  (rvalid),
    .s_axi_rready  (rready),

    .led_fault     (led_fault),
    .led_hit       (led_hit),
    .led_miss      (led_miss),
    .uart_txd      (uart_txd)
  );

endmodule
