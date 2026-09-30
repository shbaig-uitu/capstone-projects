/**
 * RISC-V SoC UVM Test Cases
 * 
 * File: uvm_riscv_test.sv
 * Description: UVM base test and specific test cases
 */

// ============================================================================
// Base Test
// ============================================================================

class riscv_uvm_base_test extends uvm_test;
  `uvm_component_utils(riscv_uvm_base_test)
  
  riscv_uvm_env env;
  virtual riscv_soc_if vif;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Get virtual interface
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("BASE_TEST_BUILD", "Virtual interface not found")
    
    // Set interface for environment
    uvm_config_db #(virtual riscv_soc_if)::set(this, "*", "vif", vif);
    
    // Instantiate environment
    env = riscv_uvm_env::type_id::create("env", this);
    
    `uvm_info("BASE_TEST_BUILD", "Base test built", UVM_MEDIUM)
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    
    uvm_print_topology();
  endfunction
  
endclass

// ============================================================================
// GPIO Pass-Through Test
// ============================================================================

class gpio_passthrough_test extends riscv_uvm_base_test;
  `uvm_component_utils(gpio_passthrough_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    gpio_passthrough_sequence seq;
    
    phase.raise_objection(this);
    
    `uvm_info("GPIO_PASS_TEST", "GPIO Pass-Through Test Starting", UVM_LOW)
    
    seq = gpio_passthrough_sequence::type_id::create("seq");
    seq.start(env.gpio_agt.sequencer);
    
    repeat(20) @(posedge vif.clk);
    
    `uvm_info("GPIO_PASS_TEST", "GPIO Pass-Through Test Completed", UVM_LOW)
    
    phase.drop_objection(this);
  endtask
  
endclass

// ============================================================================
// UART Echo Test
// ============================================================================

class uart_echo_test extends riscv_uvm_base_test;
  `uvm_component_utils(uart_echo_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    uart_echo_sequence seq;
    
    phase.raise_objection(this);
    
    `uvm_info("UART_ECHO_TEST", "UART Echo Test Starting", UVM_LOW)
    
    seq = uart_echo_sequence::type_id::create("seq");
    seq.start(env.uart_agt.sequencer);
    
    repeat(20) @(posedge vif.clk);
    
    `uvm_info("UART_ECHO_TEST", "UART Echo Test Completed", UVM_LOW)
    
    phase.drop_objection(this);
  endtask
  
endclass

// ============================================================================
// AXI Write Test
// ============================================================================

class axi_write_test extends riscv_uvm_base_test;
  `uvm_component_utils(axi_write_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    axi_write_sequence seq;
    
    phase.raise_objection(this);
    
    `uvm_info("AXI_WRITE_TEST", "AXI Write Test Starting", UVM_LOW)
    
    seq = axi_write_sequence::type_id::create("seq");
    seq.start(env.axi_agt.sequencer);
    
    repeat(50) @(posedge vif.clk);
    
    `uvm_info("AXI_WRITE_TEST", "AXI Write Test Completed", UVM_LOW)
    
    phase.drop_objection(this);
  endtask
  
endclass

// ============================================================================
// AXI Read Test
// ============================================================================

class axi_read_test extends riscv_uvm_base_test;
  `uvm_component_utils(axi_read_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    axi_read_sequence seq;
    
    phase.raise_objection(this);
    
    `uvm_info("AXI_READ_TEST", "AXI Read Test Starting", UVM_LOW)
    
    seq = axi_read_sequence::type_id::create("seq");
    seq.start(env.axi_agt.sequencer);
    
    repeat(50) @(posedge vif.clk);
    
    `uvm_info("AXI_READ_TEST", "AXI Read Test Completed", UVM_LOW)
    
    phase.drop_objection(this);
  endtask
  
endclass

// ============================================================================
// Interrupt Test
// ============================================================================

class interrupt_test extends riscv_uvm_base_test;
  `uvm_component_utils(interrupt_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    interrupt_sequence seq;
    
    phase.raise_objection(this);
    
    `uvm_info("INT_TEST", "Interrupt Test Starting", UVM_LOW)
    
    seq = interrupt_sequence::type_id::create("seq");
    seq.start(env.int_agt.sequencer);
    
    repeat(50) @(posedge vif.clk);
    
    `uvm_info("INT_TEST", "Interrupt Test Completed", UVM_LOW)
    
    phase.drop_objection(this);
  endtask
  
endclass

// ============================================================================
// Combined Regression Test
// ============================================================================

class riscv_regression_test extends riscv_uvm_base_test;
  `uvm_component_utils(riscv_regression_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    gpio_passthrough_sequence gpio_seq;
    uart_echo_sequence uart_seq;
    axi_write_sequence axi_w_seq;
    axi_read_sequence axi_r_seq;
    interrupt_sequence int_seq;
    
    phase.raise_objection(this);
    
    `uvm_info("REGRESSION_TEST", "Starting Full Regression Test", UVM_LOW)
    
    // GPIO Test
    `uvm_info("REGRESSION_TEST", ">>> Running GPIO Test", UVM_LOW)
    gpio_seq = gpio_passthrough_sequence::type_id::create("gpio_seq");
    gpio_seq.start(env.gpio_agt.sequencer);
    repeat(30) @(posedge vif.clk);
    
    // UART Test
    `uvm_info("REGRESSION_TEST", ">>> Running UART Test", UVM_LOW)
    uart_seq = uart_echo_sequence::type_id::create("uart_seq");
    uart_seq.start(env.uart_agt.sequencer);
    repeat(30) @(posedge vif.clk);
    
    // AXI Write Test
    `uvm_info("REGRESSION_TEST", ">>> Running AXI Write Test", UVM_LOW)
    axi_w_seq = axi_write_sequence::type_id::create("axi_w_seq");
    axi_w_seq.start(env.axi_agt.sequencer);
    repeat(50) @(posedge vif.clk);
    
    // AXI Read Test
    `uvm_info("REGRESSION_TEST", ">>> Running AXI Read Test", UVM_LOW)
    axi_r_seq = axi_read_sequence::type_id::create("axi_r_seq");
    axi_r_seq.start(env.axi_agt.sequencer);
    repeat(50) @(posedge vif.clk);
    
    // Interrupt Test
    `uvm_info("REGRESSION_TEST", ">>> Running Interrupt Test", UVM_LOW)
    int_seq = interrupt_sequence::type_id::create("int_seq");
    int_seq.start(env.int_agt.sequencer);
    repeat(50) @(posedge vif.clk);
    
    `uvm_info("REGRESSION_TEST", "Full Regression Test Completed", UVM_LOW)
    
    phase.drop_objection(this);
  endtask
  
endclass

