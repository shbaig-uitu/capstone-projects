// =============================================================
// debug_io.sv
// Turns live MMU events into human-visible signals for the FPGA demo:
//   led_fault : sticky, lit while a page fault is latched (cleared via AXI)
//   led_hit   : 1-cycle-stretched pulse on a TLB hit   (visible flicker)
//   led_miss  : 1-cycle-stretched pulse on a TLB miss  (visible flicker)
//   uart_txd  : one ASCII status byte per event ('H'/'M'/'F'), 8N1, for
//               a terminal on the host - LEDs alone can't be logged/timed.
// A real board demo would stretch the LED pulses further (e.g. ~0.25s)
// with a counter so the human eye can see them; a STRETCH parameter is
// provided for that on real hardware. In simulation STRETCH=1 is fine.
//
// UART event priority when multiple pulses land the same cycle:
// fault > miss > hit (fault is the rarer, more diagnostically important
// event). If the UART is still busy sending a prior byte, the new event
// is simply dropped - LEDs remain the source of truth, UART is a nice-
// to-have log, not a lossless channel.
// =============================================================
module debug_io #(
  parameter int STRETCH_BITS  = 20,        // ~1M cycles stretch for a real FPGA clock
  parameter int CLK_FREQ_HZ   = 50_000_000,
  parameter int UART_BAUD     = 115_200
)(
  input  logic clk,
  input  logic rst_n,
  input  logic fault_latched,
  input  logic hit_pulse,
  input  logic miss_pulse,
  output logic led_fault,
  output logic led_hit,
  output logic led_miss,
  output logic uart_txd
);

  // ---- UART event byte on hit/miss/fault -----------------------------
  logic       fault_latched_d;
  logic       fault_rise;
  logic [7:0] uart_tx_data;
  logic       uart_tx_valid;
  logic       uart_tx_ready;

  assign fault_rise = fault_latched & ~fault_latched_d;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) fault_latched_d <= 1'b0;
    else        fault_latched_d <= fault_latched;
  end

  always_comb begin
    uart_tx_valid = fault_rise | hit_pulse | miss_pulse;
    if (fault_rise)        uart_tx_data = "F";
    else if (miss_pulse)   uart_tx_data = "M";
    else                    uart_tx_data = "H"; // hit_pulse (or don't-care)
  end

  uart_tx #(
    .CLK_FREQ_HZ (CLK_FREQ_HZ),
    .BAUD_RATE   (UART_BAUD)
  ) u_uart_tx (
    .clk      (clk),
    .rst_n    (rst_n),
    .tx_data  (uart_tx_data),
    .tx_valid (uart_tx_valid & uart_tx_ready), // drop if busy, see header note
    .tx_ready (uart_tx_ready),
    .txd      (uart_txd)
  );

  logic [STRETCH_BITS-1:0] hit_ctr, miss_ctr;

  assign led_fault = fault_latched;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hit_ctr  <= '0;
      miss_ctr <= '0;
    end else begin
      if (hit_pulse)       hit_ctr  <= {STRETCH_BITS{1'b1}};
      else if (|hit_ctr)   hit_ctr  <= hit_ctr - 1'b1;

      if (miss_pulse)      miss_ctr <= {STRETCH_BITS{1'b1}};
      else if (|miss_ctr)  miss_ctr <= miss_ctr - 1'b1;
    end
  end

  assign led_hit  = |hit_ctr;
  assign led_miss = |miss_ctr;

endmodule
