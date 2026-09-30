/**
 * RISC-V SoC UVM Scoreboard
 * 
 * File: uvm_riscv_scoreboard.sv
 * Description: Scoreboards for comparing expected vs actual behavior
 */

// ============================================================================
// GPIO Scoreboard
// ============================================================================

class gpio_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(gpio_scoreboard)
  
  uvm_analysis_export #(gpio_transaction) ap;
  uvm_tlm_analysis_fifo #(gpio_transaction) fifo;
  
  int gpio_pass = 0;
  int gpio_fail = 0;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    ap = new("ap", this);
    fifo = new("fifo", this);
    
    `uvm_info("GPIO_SB_BUILD", "GPIO Scoreboard built", UVM_MEDIUM)
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ap.connect(fifo.analysis_export);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      gpio_transaction trans;
      fifo.get(trans);
      
      if(trans.gpio_out == trans.gpio_expected) begin
        `uvm_info("GPIO_SB_PASS", 
                  $sformatf("PASS: IN=0x%02X OUT=0x%02X", trans.gpio_in, trans.gpio_out),
                  UVM_HIGH)
        gpio_pass++;
      end else begin
        `uvm_error("GPIO_SB_FAIL",
                   $sformatf("FAIL: IN=0x%02X OUT=0x%02X EXP=0x%02X",
                            trans.gpio_in, trans.gpio_out, trans.gpio_expected))
        gpio_fail++;
      end
    end
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info("GPIO_SB_REPORT",
              $sformatf("GPIO Results - PASS: %0d FAIL: %0d", gpio_pass, gpio_fail),
              UVM_LOW)
  endfunction
  
endclass

// ============================================================================
// UART Scoreboard
// ============================================================================

class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)
  
  uvm_analysis_export #(uart_transaction) ap;
  uvm_tlm_analysis_fifo #(uart_transaction) fifo;
  
  int uart_pass = 0;
  int uart_fail = 0;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    ap = new("ap", this);
    fifo = new("fifo", this);
    
    `uvm_info("UART_SB_BUILD", "UART Scoreboard built", UVM_MEDIUM)
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ap.connect(fifo.analysis_export);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      uart_transaction trans;
      fifo.get(trans);
      
      if(trans.uart_tx == trans.uart_expected) begin
        `uvm_info("UART_SB_PASS",
                  $sformatf("PASS: RX=%b TX=%b", trans.uart_rx, trans.uart_tx),
                  UVM_HIGH)
        uart_pass++;
      end else begin
        `uvm_error("UART_SB_FAIL",
                   $sformatf("FAIL: RX=%b TX=%b EXP=%b",
                            trans.uart_rx, trans.uart_tx, trans.uart_expected))
        uart_fail++;
      end
    end
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info("UART_SB_REPORT",
              $sformatf("UART Results - PASS: %0d FAIL: %0d", uart_pass, uart_fail),
              UVM_LOW)
  endfunction
  
endclass

// ============================================================================
// AXI Scoreboard
// ============================================================================

class axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_scoreboard)
  
  uvm_analysis_export #(axi_transaction) ap;
  uvm_tlm_analysis_fifo #(axi_transaction) fifo;
  
  int axi_pass = 0;
  int axi_fail = 0;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    ap = new("ap", this);
    fifo = new("fifo", this);
    
    `uvm_info("AXI_SB_BUILD", "AXI Scoreboard built", UVM_MEDIUM)
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ap.connect(fifo.analysis_export);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      axi_transaction trans;
      fifo.get(trans);
      
      // Check for valid response (OKAY = 2'b00)
      if(trans.resp == 2'b00) begin
        `uvm_info("AXI_SB_PASS",
                  $sformatf("PASS: ADDR=0x%08X DATA=0x%08X RESP=%b",
                           trans.addr, trans.data, trans.resp),
                  UVM_HIGH)
        axi_pass++;
      end else begin
        `uvm_error("AXI_SB_FAIL",
                   $sformatf("FAIL: ADDR=0x%08X DATA=0x%08X RESP=%b (non-OKAY response)",
                            trans.addr, trans.data, trans.resp))
        axi_fail++;
      end
    end
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info("AXI_SB_REPORT",
              $sformatf("AXI Results - PASS: %0d FAIL: %0d", axi_pass, axi_fail),
              UVM_LOW)
  endfunction
  
endclass

// ============================================================================
// Top-Level Scoreboard
// ============================================================================

class top_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(top_scoreboard)
  
  gpio_scoreboard gpio_sb;
  uart_scoreboard uart_sb;
  axi_scoreboard axi_sb;
  
  int total_pass = 0;
  int total_fail = 0;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    gpio_sb = gpio_scoreboard::type_id::create("gpio_sb", this);
    uart_sb = uart_scoreboard::type_id::create("uart_sb", this);
    axi_sb = axi_scoreboard::type_id::create("axi_sb", this);
    
    `uvm_info("TOP_SB_BUILD", "Top Scoreboard built", UVM_MEDIUM)
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    total_pass = gpio_sb.gpio_pass + uart_sb.uart_pass + axi_sb.axi_pass;
    total_fail = gpio_sb.gpio_fail + uart_sb.uart_fail + axi_sb.axi_fail;
    
    `uvm_info("TOP_SB_REPORT", "=" * 80, UVM_LOW)
    `uvm_info("TOP_SB_REPORT", "VERIFICATION SUMMARY", UVM_LOW)
    `uvm_info("TOP_SB_REPORT", "=" * 80, UVM_LOW)
    `uvm_info("TOP_SB_REPORT",
              $sformatf("GPIO Tests:      PASS=%0d  FAIL=%0d", gpio_sb.gpio_pass, gpio_sb.gpio_fail),
              UVM_LOW)
    `uvm_info("TOP_SB_REPORT",
              $sformatf("UART Tests:      PASS=%0d  FAIL=%0d", uart_sb.uart_pass, uart_sb.uart_fail),
              UVM_LOW)
    `uvm_info("TOP_SB_REPORT",
              $sformatf("AXI Tests:       PASS=%0d  FAIL=%0d", axi_sb.axi_pass, axi_sb.axi_fail),
              UVM_LOW)
    `uvm_info("TOP_SB_REPORT", "-" * 80, UVM_LOW)
    `uvm_info("TOP_SB_REPORT",
              $sformatf("TOTAL:           PASS=%0d  FAIL=%0d", total_pass, total_fail),
              UVM_LOW)
    `uvm_info("TOP_SB_REPORT", "=" * 80, UVM_LOW)
    
    if(total_fail == 0) begin
      `uvm_info("TOP_SB_REPORT", ">>> ALL TESTS PASSED <<<", UVM_LOW)
    end else begin
      `uvm_error("TOP_SB_REPORT", $sformatf(">>> %0d TESTS FAILED <<<", total_fail))
    end
    `uvm_info("TOP_SB_REPORT", "=" * 80, UVM_LOW)
  endfunction
  
endclass

