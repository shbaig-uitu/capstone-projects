module dual_core_soc(
`ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
`endif

    input  clk,
    input  reset,

    output uart_tx_line,
    input  uart_rx_line
);

wire [31:0] core0_pc;
wire [31:0] core0_instruction;

wire [31:0] core1_pc;
wire [31:0] core1_instruction;

wire        core0_read;
wire        core0_write;
wire [3:0]  core0_write_strobe;

wire [31:0] core0_address;
wire [31:0] core0_write_data;
wire [31:0] core0_read_data;

wire        core0_ready;

wire        core1_read;
wire        core1_write;
wire [3:0]  core1_write_strobe;

wire [31:0] core1_address;
wire [31:0] core1_write_data;
wire [31:0] core1_read_data;

wire        core1_ready;

instruction_memory #(
    .INIT_FILE("firmware_core0.hex")
)
imem_core0 (
    .clk             (clk),

    .boot_write      (1'b0),
    .boot_address    (8'b0),
    .boot_write_data (32'b0),

    .address         (core0_pc),
    .instruction     (core0_instruction)
);

instruction_memory #(
    .INIT_FILE("firmware_core1.hex")
)
imem_core1 (
    .clk             (clk),

    .boot_write      (1'b0),
    .boot_address    (8'b0),
    .boot_write_data (32'b0),

    .address         (core1_pc),
    .instruction     (core1_instruction)
);

rv32i_core core0 (
    .clk              (clk),
    .reset            (reset),

    
    .pc               (core0_pc),
    .instruction      (core0_instruction),

    
    .mem_read         (core0_read),
    .mem_write        (core0_write),
    .mem_write_strobe (core0_write_strobe),

    .mem_address      (core0_address),
    .mem_write_data   (core0_write_data),

    .mem_read_data    (core0_read_data),
    .mem_ready        (core0_ready)
);

rv32i_core core1 (
    .clk              (clk),
    .reset            (reset),

    
    .pc               (core1_pc),
    .instruction      (core1_instruction),

    
    .mem_read         (core1_read),
    .mem_write        (core1_write),
    .mem_write_strobe (core1_write_strobe),

    .mem_address      (core1_address),
    .mem_write_data   (core1_write_data),

    .mem_read_data    (core1_read_data),
    .mem_ready        (core1_ready)
);

mailbox_system system (
`ifdef USE_POWER_PINS
    .VPWR               (VPWR),
    .VGND               (VGND),
`endif

    .clk                 (clk),
    .reset               (reset),

    
    .core0_read          (core0_read),
    .core0_write         (core0_write),
    .core0_write_strobe  (core0_write_strobe),

    .core0_address       (core0_address),
    .core0_write_data    (core0_write_data),

    .core0_read_data     (core0_read_data),
    .core0_ready         (core0_ready),

    
    .core1_read          (core1_read),
    .core1_write         (core1_write),
    .core1_write_strobe  (core1_write_strobe),

    .core1_address       (core1_address),
    .core1_write_data    (core1_write_data),

    .core1_read_data     (core1_read_data),
    .core1_ready         (core1_ready),

    
    .uart_tx_line        (uart_tx_line),
    .uart_rx_line        (uart_rx_line)
);

endmodule

