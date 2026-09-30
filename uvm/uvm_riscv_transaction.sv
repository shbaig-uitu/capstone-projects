/**
 * RISC-V SoC UVM Transaction
 * 
 * File: uvm_riscv_transaction.sv
 * Description: Base transaction classes for RISC-V SoC verification
 */

// ============================================================================
// GPIO Transaction
// ============================================================================

class gpio_transaction extends uvm_sequence_item;
  `uvm_object_utils(gpio_transaction)
  
  logic [7:0]  gpio_in;
  logic [7:0]  gpio_out;
  logic [7:0]  gpio_expected;
  
  function new(string name = "gpio_transaction");
    super.new(name);
    gpio_in = '0;
    gpio_out = '0;
    gpio_expected = '0;
  endfunction
  
  function void do_copy(uvm_object rhs);
    gpio_transaction rhs_;
    if(!$cast(rhs_, rhs)) begin
      `uvm_fatal("do_copy", "Cast failed")
    end
    super.do_copy(rhs);
    gpio_in = rhs_.gpio_in;
    gpio_out = rhs_.gpio_out;
    gpio_expected = rhs_.gpio_expected;
  endfunction
  
  function string convert2string();
    return $sformatf("GPIO_TRANS: IN=0x%02X, OUT=0x%02X, EXP=0x%02X",
                     gpio_in, gpio_out, gpio_expected);
  endfunction
endclass

// ============================================================================
// UART Transaction
// ============================================================================

class uart_transaction extends uvm_sequence_item;
  `uvm_object_utils(uart_transaction)
  
  logic        uart_rx;
  logic        uart_tx;
  logic        uart_expected;
  
  function new(string name = "uart_transaction");
    super.new(name);
    uart_rx = 1'b0;
    uart_tx = 1'b0;
    uart_expected = 1'b0;
  endfunction
  
  function void do_copy(uvm_object rhs);
    uart_transaction rhs_;
    if(!$cast(rhs_, rhs)) begin
      `uvm_fatal("do_copy", "Cast failed")
    end
    super.do_copy(rhs);
    uart_rx = rhs_.uart_rx;
    uart_tx = rhs_.uart_tx;
    uart_expected = rhs_.uart_expected;
  endfunction
  
  function string convert2string();
    return $sformatf("UART_TRANS: RX=%b, TX=%b, EXP=%b",
                     uart_rx, uart_tx, uart_expected);
  endfunction
endclass

// ============================================================================
// AXI4-Lite Transaction
// ============================================================================

typedef enum {
  AXI_WRITE,
  AXI_READ
} axi_trans_type_t;

class axi_transaction extends uvm_sequence_item;
  `uvm_object_utils(axi_transaction)
  
  axi_trans_type_t  trans_type;
  logic [31:0]      addr;
  logic [31:0]      data;
  logic [3:0]       strb;
  logic [1:0]       resp;
  logic             error;
  
  function new(string name = "axi_transaction");
    super.new(name);
    trans_type = AXI_READ;
    addr = '0;
    data = '0;
    strb = 4'hF;
    resp = 2'b00;
    error = 1'b0;
  endfunction
  
  function void do_copy(uvm_object rhs);
    axi_transaction rhs_;
    if(!$cast(rhs_, rhs)) begin
      `uvm_fatal("do_copy", "Cast failed")
    end
    super.do_copy(rhs);
    trans_type = rhs_.trans_type;
    addr = rhs_.addr;
    data = rhs_.data;
    strb = rhs_.strb;
    resp = rhs_.resp;
    error = rhs_.error;
  endfunction
  
  function string convert2string();
    string trans_str = (trans_type == AXI_WRITE) ? "WRITE" : "READ";
    return $sformatf("AXI_TRANS(%s): ADDR=0x%08X, DATA=0x%08X, RESP=%b, ERR=%b",
                     trans_str, addr, data, resp, error);
  endfunction
endclass

// ============================================================================
// Interrupt Transaction
// ============================================================================

class interrupt_transaction extends uvm_sequence_item;
  `uvm_object_utils(interrupt_transaction)
  
  logic        ext_interrupt;
  int          delay_cycles;
  
  function new(string name = "interrupt_transaction");
    super.new(name);
    ext_interrupt = 1'b0;
    delay_cycles = 0;
  endfunction
  
  function void do_copy(uvm_object rhs);
    interrupt_transaction rhs_;
    if(!$cast(rhs_, rhs)) begin
      `uvm_fatal("do_copy", "Cast failed")
    end
    super.do_copy(rhs);
    ext_interrupt = rhs_.ext_interrupt;
    delay_cycles = rhs_.delay_cycles;
  endfunction
  
  function string convert2string();
    return $sformatf("INT_TRANS: IRQ=%b, DELAY=%0d cycles",
                     ext_interrupt, delay_cycles);
  endfunction
endclass

// ============================================================================
// Clock Transaction
// ============================================================================

class clock_transaction extends uvm_sequence_item;
  `uvm_object_utils(clock_transaction)
  
  int          num_cycles;
  logic        reset_active;
  
  function new(string name = "clock_transaction");
    super.new(name);
    num_cycles = 100;
    reset_active = 1'b0;
  endfunction
  
  function void do_copy(uvm_object rhs);
    clock_transaction rhs_;
    if(!$cast(rhs_, rhs)) begin
      `uvm_fatal("do_copy", "Cast failed")
    end
    super.do_copy(rhs);
    num_cycles = rhs_.num_cycles;
    reset_active = rhs_.reset_active;
  endfunction
  
  function string convert2string();
    return $sformatf("CLK_TRANS: CYCLES=%0d, RESET=%b",
                     num_cycles, reset_active);
  endfunction
endclass
