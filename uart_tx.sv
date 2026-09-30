// =============================================================
// uart_tx.sv
// Minimal 8N1 UART transmitter, ready/valid handshake.
//   tx_valid : caller asserts with tx_data stable, holds until tx_ready
//   tx_ready : high when idle and able to accept a new byte
//   txd      : idles high, standard 8N1 framing (1 start, 8 data LSB-first,
//              1 stop)
// CLK_FREQ_HZ / BAUD_RATE pick the bit-period counter; defaults assume a
// 50 MHz board clock and a common 115200 baud demo rate. Re-parameterize
// per board.
// =============================================================
module uart_tx #(
  parameter int CLK_FREQ_HZ = 50_000_000,
  parameter int BAUD_RATE   = 115_200
)(
  input  logic       clk,
  input  logic       rst_n,
  input  logic [7:0] tx_data,
  input  logic       tx_valid,
  output logic       tx_ready,
  output logic       txd
);

  localparam int CYCLES_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
  localparam int CNT_BITS       = $clog2(CYCLES_PER_BIT);

  typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_e;
  state_e state;

  logic [CNT_BITS-1:0] cyc_cnt;
  logic [2:0]           bit_idx;
  logic [7:0]            shift_reg;

  assign tx_ready = (state == IDLE);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state     <= IDLE;
      txd       <= 1'b1;
      cyc_cnt   <= '0;
      bit_idx   <= '0;
      shift_reg <= '0;
    end else begin
      case (state)
        IDLE: begin
          txd <= 1'b1;
          if (tx_valid) begin
            shift_reg <= tx_data;
            state     <= START;
            cyc_cnt   <= '0;
          end
        end

        START: begin
          txd <= 1'b0; // start bit
          if (cyc_cnt == CYCLES_PER_BIT-1) begin
            cyc_cnt <= '0;
            bit_idx <= '0;
            state   <= DATA;
          end else cyc_cnt <= cyc_cnt + 1'b1;
        end

        DATA: begin
          txd <= shift_reg[0];
          if (cyc_cnt == CYCLES_PER_BIT-1) begin
            cyc_cnt   <= '0;
            shift_reg <= {1'b0, shift_reg[7:1]};
            if (bit_idx == 3'd7) state <= STOP;
            else                 bit_idx <= bit_idx + 1'b1;
          end else cyc_cnt <= cyc_cnt + 1'b1;
        end

        STOP: begin
          txd <= 1'b1; // stop bit
          if (cyc_cnt == CYCLES_PER_BIT-1) begin
            cyc_cnt <= '0;
            state   <= IDLE;
          end else cyc_cnt <= cyc_cnt + 1'b1;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
