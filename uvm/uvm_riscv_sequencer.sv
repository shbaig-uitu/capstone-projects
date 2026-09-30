/**
 * RISC-V SoC UVM Sequencer
 * 
 * File: uvm_riscv_sequencer.sv
 * Description: UVM sequencers for controlling stimulus generation
 */

// ============================================================================
// GPIO Sequencer
// ============================================================================

class gpio_sequencer extends uvm_sequencer #(gpio_transaction);
  `uvm_component_utils(gpio_sequencer)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("GPIO_SEQ_BUILD", "GPIO Sequencer built", UVM_MEDIUM)
  endfunction
  
endclass

// ============================================================================
// UART Sequencer
// ============================================================================

class uart_sequencer extends uvm_sequencer #(uart_transaction);
  `uvm_component_utils(uart_sequencer)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("UART_SEQ_BUILD", "UART Sequencer built", UVM_MEDIUM)
  endfunction
  
endclass

// ============================================================================
// AXI4-Lite Sequencer
// ============================================================================

class axi_sequencer extends uvm_sequencer #(axi_transaction);
  `uvm_component_utils(axi_sequencer)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AXI_SEQ_BUILD", "AXI Sequencer built", UVM_MEDIUM)
  endfunction
  
endclass

// ============================================================================
// Interrupt Sequencer
// ============================================================================

class interrupt_sequencer extends uvm_sequencer #(interrupt_transaction);
  `uvm_component_utils(interrupt_sequencer)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("INT_SEQ_BUILD", "Interrupt Sequencer built", UVM_MEDIUM)
  endfunction
  
endclass

