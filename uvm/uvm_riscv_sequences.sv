/**
 * RISC-V SoC UVM Test Sequences
 * 
 * File: uvm_riscv_sequences.sv
 * Description: Test sequences for various verification scenarios
 */

// ============================================================================
// GPIO Pass-Through Sequence
// ============================================================================

class gpio_passthrough_sequence extends uvm_sequence #(gpio_transaction);
  `uvm_object_utils(gpio_passthrough_sequence)
  
  function new(string name = "gpio_passthrough_sequence");
    super.new(name);
  endfunction
  
  task body();
    gpio_transaction trans;
    logic [7:0] gpio_pattern;
    
    `uvm_info("GPIO_PASS_SEQ", "Starting GPIO pass-through sequence", UVM_MEDIUM)
    
    // Test multiple patterns
    foreach(gpio_pattern[i]) begin
      trans = gpio_transaction::type_id::create("trans");
      assert(trans.randomize() with {gpio_in == (1 << i);}) else
        `uvm_error("GPIO_PASS_SEQ", "Randomization failed")
      start_item(trans);
      finish_item(trans);
      @(posedge m_sequencer.vif.clk);
    end
    
    // Special patterns
    trans = gpio_transaction::type_id::create("trans");
    trans.gpio_in = 8'hAA;
    trans.gpio_expected = 8'hAA;
    start_item(trans);
    finish_item(trans);
    @(posedge m_sequencer.vif.clk);
    
    trans = gpio_transaction::type_id::create("trans");
    trans.gpio_in = 8'h55;
    trans.gpio_expected = 8'h55;
    start_item(trans);
    finish_item(trans);
    @(posedge m_sequencer.vif.clk);
    
    `uvm_info("GPIO_PASS_SEQ", "GPIO pass-through sequence completed", UVM_MEDIUM)
  endtask
  
endclass

// ============================================================================
// UART Echo Sequence
// ============================================================================

class uart_echo_sequence extends uvm_sequence #(uart_transaction);
  `uvm_object_utils(uart_echo_sequence)
  
  function new(string name = "uart_echo_sequence");
    super.new(name);
  endfunction
  
  task body();
    uart_transaction trans;
    
    `uvm_info("UART_ECHO_SEQ", "Starting UART echo sequence", UVM_MEDIUM)
    
    // Send multiple 1's and 0's for UART loopback test
    repeat(10) begin
      trans = uart_transaction::type_id::create("trans");
      assert(trans.randomize()) else
        `uvm_error("UART_ECHO_SEQ", "Randomization failed")
      trans.uart_expected = trans.uart_rx;  // Expected is echoed back
      start_item(trans);
      finish_item(trans);
      @(posedge m_sequencer.vif.clk);
    end
    
    `uvm_info("UART_ECHO_SEQ", "UART echo sequence completed", UVM_MEDIUM)
  endtask
  
endclass

// ============================================================================
// AXI Write Sequence
// ============================================================================

class axi_write_sequence extends uvm_sequence #(axi_transaction);
  `uvm_object_utils(axi_write_sequence)
  
  function new(string name = "axi_write_sequence");
    super.new(name);
  endfunction
  
  task body();
    axi_transaction trans;
    
    `uvm_info("AXI_WRITE_SEQ", "Starting AXI write sequence", UVM_MEDIUM)
    
    repeat(5) begin
      trans = axi_transaction::type_id::create("trans");
      assert(trans.randomize() with {
        trans_type == AXI_WRITE;
        addr inside {[32'h80000000:32'h800000FF]};
      }) else
        `uvm_error("AXI_WRITE_SEQ", "Randomization failed")
      start_item(trans);
      finish_item(trans);
      @(posedge m_sequencer.vif.clk);
    end
    
    `uvm_info("AXI_WRITE_SEQ", "AXI write sequence completed", UVM_MEDIUM)
  endtask
  
endclass

// ============================================================================
// AXI Read Sequence
// ============================================================================

class axi_read_sequence extends uvm_sequence #(axi_transaction);
  `uvm_object_utils(axi_read_sequence)
  
  function new(string name = "axi_read_sequence");
    super.new(name);
  endfunction
  
  task body();
    axi_transaction trans;
    
    `uvm_info("AXI_READ_SEQ", "Starting AXI read sequence", UVM_MEDIUM)
    
    repeat(5) begin
      trans = axi_transaction::type_id::create("trans");
      assert(trans.randomize() with {
        trans_type == AXI_READ;
        addr inside {[32'h00000000:32'h00003FFF]};
      }) else
        `uvm_error("AXI_READ_SEQ", "Randomization failed")
      start_item(trans);
      finish_item(trans);
      @(posedge m_sequencer.vif.clk);
    end
    
    `uvm_info("AXI_READ_SEQ", "AXI read sequence completed", UVM_MEDIUM)
  endtask
  
endclass

// ============================================================================
// Interrupt Sequence
// ============================================================================

class interrupt_sequence extends uvm_sequence #(interrupt_transaction);
  `uvm_object_utils(interrupt_sequence)
  
  function new(string name = "interrupt_sequence");
    super.new(name);
  endfunction
  
  task body();
    interrupt_transaction trans;
    
    `uvm_info("INT_SEQ", "Starting interrupt sequence", UVM_MEDIUM)
    
    // External interrupt pulse
    trans = interrupt_transaction::type_id::create("trans");
    trans.ext_interrupt = 1'b1;
    trans.delay_cycles = 10;
    start_item(trans);
    finish_item(trans);
    
    // Hold for a few cycles
    repeat(20) @(posedge m_sequencer.vif.clk);
    
    // De-assert interrupt
    trans = interrupt_transaction::type_id::create("trans");
    trans.ext_interrupt = 1'b0;
    trans.delay_cycles = 0;
    start_item(trans);
    finish_item(trans);
    
    `uvm_info("INT_SEQ", "Interrupt sequence completed", UVM_MEDIUM)
  endtask
  
endclass

// ============================================================================
// Reset Sequence
// ============================================================================

class reset_sequence extends uvm_sequence #(gpio_transaction);
  `uvm_object_utils(reset_sequence)
  
  virtual riscv_soc_if vif;
  
  function new(string name = "reset_sequence");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("RESET_SEQ", "Reset sequence executing", UVM_MEDIUM)
    
    // Just observe reset sequencing
    repeat(10) @(posedge vif.clk);
    
    if(vif.rst_n == 1'b1) begin
      `uvm_info("RESET_SEQ", "Device reset complete, operating normally", UVM_MEDIUM)
    end else begin
      `uvm_error("RESET_SEQ", "Device still in reset!")
    end
  endtask
  
endclass

