// arty_top.v - FPGA Top Level Module for Digilent Arty A7-100T
`default_nettype none

module arty_top (
    input  wire       CLK100MHZ,   // 100 MHz oscillator (Pin E3)
    input  wire [3:0] sw,          // Onboard Switches (Pins A8, C11, C10, A10)
    input  wire [3:0] btn,         // Onboard Buttons (Pins D9, C9, B9, B8)
    output wire [3:0] led,         // Green User LEDs (Pins H5, J5, T9, T10)
    output wire       uart_rxd_out,// FPGA UART TX to PC (Pin D10)
    input  wire       uart_txd_in  // FPGA UART RX from PC (Pin A9)
);

    // 2. Hardware PLL: 100 MHz -> 25 MHz Dedicated Global Clock
    // 25 MHz (40 ns period) comfortably meets the 35.6 ns datapath delay,
    // eliminating all setup violations on physical silicon!
    wire clkfb, clk25_unbuf, clk, pll_locked;

    PLLE2_ADV #(
        .CLKFBOUT_MULT(12),       // VCO = 100 * 12 = 1200 MHz
        .CLKIN1_PERIOD(10.0),
        .CLKOUT0_DIVIDE(48),     // 1200 / 48 = 25.0 MHz
        .CLKOUT0_PHASE(0.0),
        .DIVCLK_DIVIDE(1),
        .REF_JITTER1(0.01),
        .STARTUP_WAIT("FALSE")
    ) pll_inst (
        .CLKFBIN (clkfb),
        .CLKIN1  (CLK100MHZ),
        .CLKFBOUT(clkfb),
        .CLKOUT0 (clk25_unbuf),
        .LOCKED  (pll_locked),
        .PWRDWN  (1'b0),
        .RST     (1'b0)
    );

    BUFG clk_buf (.I(clk25_unbuf), .O(clk));

    // 1. Reset logic with Hardware Debouncer (eliminates button contact chatter)
    // 10 ms filter @ 25 MHz (250,000 cycles)
    reg [17:0] db_cnt = 18'd0;
    reg rst_btn_clean = 1'b1;
    wire rst_raw = sw[3] | btn[0];

    always @(posedge clk or negedge pll_locked) begin
        if (!pll_locked) begin
            db_cnt <= 18'd0;
            rst_btn_clean <= 1'b1;
        end else begin
            if (rst_raw != rst_btn_clean) begin
                db_cnt <= db_cnt + 1'b1;
                if (db_cnt >= 18'd250_000) begin
                    rst_btn_clean <= rst_raw;
                    db_cnt <= 18'd0;
                end
            end else begin
                db_cnt <= 18'd0;
            end
        end
    end

    wire rst = rst_btn_clean;

    // 3. Heartbeat Generator (~1.5 Hz blink for visual liveness at 25 MHz)
    reg [23:0] hb_cnt = 24'd0;
    always @(posedge clk) begin
        hb_cnt <= hb_cnt + 1'b1;
    end
    wire heartbeat = hb_cnt[23];

    // 4. Instantiate the SoC
    wire [3:0]  soc_led;
    wire        accel_comp;
    wire        accel_done;
    wire [31:0] soc_x7;
    wire [31:0] soc_x8;
    wire [31:0] soc_c00;

    soc_top soc_inst (
        .clk(clk),
        .rst(rst),
        .led(soc_led),
        .accel_computing(accel_comp),
        .accel_done(accel_done),
        .cpu_x7(soc_x7),
        .cpu_x8(soc_x8),
        .c00_out(soc_c00)
    );

    // 5. LED Output Mode Selection using Switch 0:
    // sw[0] == 0 (Default): Direct CPU verification status
    //                       0001 (loading) -> 0010 (computing) -> 1111 (PASS!)
    // sw[0] == 1: Status display
    //             led[0] = Heartbeat
    //             led[1] = Accelerator Computing
    //             led[2] = Accelerator Done
    //             led[3] = Math PASS
    assign led = sw[0] ? {soc_led[3], accel_done, accel_comp, heartbeat} : soc_led;

    // 6. UART Transmitter (115200 Baud @ 25 MHz)
    // Sends formatted diagnostic telemetry over /dev/ttyUSB1:
    // "\r\n[TPU] C00=0xXXXXXXXX x7=0xXXXXXXXX x8=0xXXXXXXXX LED=XXXX (PASS)\r\n"
    localparam CLKS_PER_BIT = 217; // 25,000,000 / 115200 = 217.01
    reg [7:0]  tx_data;
    reg        tx_start = 0;
    wire       tx_busy;

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_uart (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_out(uart_rxd_out),
        .tx_busy(tx_busy)
    );

    wire is_pass = (soc_led == 4'b1111);
    wire is_fail = (soc_led == 4'b0101);

    function [7:0] to_hex(input [3:0] n);
        to_hex = (n < 4'd10) ? (8'd48 + {4'b0, n}) : (8'd55 + {4'b0, n});
    endfunction

    // Dynamic message function (68 bytes)
    function [7:0] get_msg_byte(
        input [6:0]  idx,
        input [31:0] c_val,
        input [31:0] x7_val,
        input [31:0] x8_val,
        input [3:0]  l_val,
        input        pass
    );
        case (idx)
            7'd00: get_msg_byte = "\r";
            7'd01: get_msg_byte = "\n";
            7'd02: get_msg_byte = "[";
            7'd03: get_msg_byte = "T";
            7'd04: get_msg_byte = "P";
            7'd05: get_msg_byte = "U";
            7'd06: get_msg_byte = "]";
            7'd07: get_msg_byte = " ";
            7'd08: get_msg_byte = "C";
            7'd09: get_msg_byte = "0";
            7'd10: get_msg_byte = "0";
            7'd11: get_msg_byte = "=";
            7'd12: get_msg_byte = "0";
            7'd13: get_msg_byte = "x";
            7'd14: get_msg_byte = to_hex(c_val[31:28]);
            7'd15: get_msg_byte = to_hex(c_val[27:24]);
            7'd16: get_msg_byte = to_hex(c_val[23:20]);
            7'd17: get_msg_byte = to_hex(c_val[19:16]);
            7'd18: get_msg_byte = to_hex(c_val[15:12]);
            7'd19: get_msg_byte = to_hex(c_val[11:8]);
            7'd20: get_msg_byte = to_hex(c_val[7:4]);
            7'd21: get_msg_byte = to_hex(c_val[3:0]);
            7'd22: get_msg_byte = " ";
            7'd23: get_msg_byte = "x";
            7'd24: get_msg_byte = "7";
            7'd25: get_msg_byte = "=";
            7'd26: get_msg_byte = "0";
            7'd27: get_msg_byte = "x";
            7'd28: get_msg_byte = to_hex(x7_val[31:28]);
            7'd29: get_msg_byte = to_hex(x7_val[27:24]);
            7'd30: get_msg_byte = to_hex(x7_val[23:20]);
            7'd31: get_msg_byte = to_hex(x7_val[19:16]);
            7'd32: get_msg_byte = to_hex(x7_val[15:12]);
            7'd33: get_msg_byte = to_hex(x7_val[11:8]);
            7'd34: get_msg_byte = to_hex(x7_val[7:4]);
            7'd35: get_msg_byte = to_hex(x7_val[3:0]);
            7'd36: get_msg_byte = " ";
            7'd37: get_msg_byte = "x";
            7'd38: get_msg_byte = "8";
            7'd39: get_msg_byte = "=";
            7'd40: get_msg_byte = "0";
            7'd41: get_msg_byte = "x";
            7'd42: get_msg_byte = to_hex(x8_val[31:28]);
            7'd43: get_msg_byte = to_hex(x8_val[27:24]);
            7'd44: get_msg_byte = to_hex(x8_val[23:20]);
            7'd45: get_msg_byte = to_hex(x8_val[19:16]);
            7'd46: get_msg_byte = to_hex(x8_val[15:12]);
            7'd47: get_msg_byte = to_hex(x8_val[11:8]);
            7'd48: get_msg_byte = to_hex(x8_val[7:4]);
            7'd49: get_msg_byte = to_hex(x8_val[3:0]);
            7'd50: get_msg_byte = " ";
            7'd51: get_msg_byte = "L";
            7'd52: get_msg_byte = "E";
            7'd53: get_msg_byte = "D";
            7'd54: get_msg_byte = "=";
            7'd55: get_msg_byte = l_val[3] ? "1" : "0";
            7'd56: get_msg_byte = l_val[2] ? "1" : "0";
            7'd57: get_msg_byte = l_val[1] ? "1" : "0";
            7'd58: get_msg_byte = l_val[0] ? "1" : "0";
            7'd59: get_msg_byte = " ";
            7'd60: get_msg_byte = "(";
            7'd61: get_msg_byte = pass ? "P" : "F";
            7'd62: get_msg_byte = pass ? "A" : "A";
            7'd63: get_msg_byte = pass ? "S" : "I";
            7'd64: get_msg_byte = pass ? "S" : "L";
            7'd65: get_msg_byte = ")";
            7'd66: get_msg_byte = "\r";
            7'd67: get_msg_byte = "\n";
            default: get_msg_byte = " ";
        endcase
    endfunction

    // UART transmission FSM
    reg [6:0]  msg_idx = 0;
    reg [1:0]  uart_state = 0;
    reg        tx_reported = 0;
    reg        pass_latch  = 0;
    reg [31:0] lat_c00 = 0;
    reg [31:0] lat_x7  = 0;
    reg [31:0] lat_x8  = 0;
    reg [3:0]  lat_led = 0;

    always @(posedge clk) begin
        if (rst) begin
            msg_idx     <= 0;
            uart_state  <= 0;
            tx_start    <= 0;
            tx_reported <= 0;
            pass_latch  <= 0;
            lat_c00     <= 0;
            lat_x7      <= 0;
            lat_x8      <= 0;
            lat_led     <= 0;
        end else begin
            case (uart_state)
                0: begin
                    // Trigger transmission once when test finishes (PASS or FAIL)
                    if (!tx_reported && (is_pass || is_fail)) begin
                        msg_idx     <= 0;
                        pass_latch  <= is_pass;
                        lat_c00     <= soc_c00;
                        lat_x7      <= soc_x7;
                        lat_x8      <= soc_x8;
                        lat_led     <= soc_led;
                        tx_reported <= 1'b1;
                        uart_state  <= 1;
                    end
                end
                1: begin
                    if (!tx_busy) begin
                        tx_data    <= get_msg_byte(msg_idx, lat_c00, lat_x7, lat_x8, lat_led, pass_latch);
                        tx_start   <= 1'b1;
                        uart_state <= 2;
                    end
                end
                2: begin
                    tx_start <= 1'b0;
                    if (msg_idx == 7'd67) begin
                        uart_state <= 0; // Finished transmission
                    end else begin
                        msg_idx    <= msg_idx + 1'b1;
                        uart_state <= 1;
                    end
                end
            endcase
        end
    end

endmodule

// Lightweight UART Transmitter Module
module uart_tx #(parameter CLKS_PER_BIT = 217)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_out,
    output reg        tx_busy
);
    localparam S_IDLE  = 0;
    localparam S_START = 1;
    localparam S_DATA  = 2;
    localparam S_STOP  = 3;

    reg [1:0]  state = S_IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0]  bit_index = 0;
    reg [7:0]  data_lat  = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= S_IDLE;
            tx_out    <= 1'b1;
            tx_busy   <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    tx_out    <= 1'b1;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (tx_start) begin
                        data_lat <= tx_data;
                        tx_busy  <= 1'b1;
                        state    <= S_START;
                    end else begin
                        tx_busy  <= 1'b0;
                    end
                end

                S_START: begin
                    tx_out <= 1'b0; // Start bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 0;
                        state     <= S_DATA;
                    end
                end

                S_DATA: begin
                    tx_out <= data_lat[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1'b1;
                        end else begin
                            bit_index <= 0;
                            state     <= S_STOP;
                        end
                    end
                end

                S_STOP: begin
                    tx_out <= 1'b1; // Stop bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 0;
                        state     <= S_IDLE;
                    end
                end
            endcase
        end
    end
endmodule
`default_nettype wire
