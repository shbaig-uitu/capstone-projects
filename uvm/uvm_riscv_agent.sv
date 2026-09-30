/**
 * RISC-V SoC UVM Agent
 * 
 * File: uvm_riscv_agent.sv
 * Description: UVM agents that instantiate sequencer, driver, and monitor
 */

// ============================================================================
// GPIO Agent
// ============================================================================

class gpio_agent extends uvm_agent;
  `uvm_component_utils(gpio_agent)
  
  gpio_sequencer sequencer;
  gpio_driver driver;
  gpio_monitor monitor;
  
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = gpio_monitor::type_id::create("monitor", this);
    
    if(is_active == UVM_ACTIVE) begin
      sequencer = gpio_sequencer::type_id::create("sequencer", this);
      driver = gpio_driver::type_id::create("driver", this);
    end
    
    `uvm_info("GPIO_AGENT_BUILD", "GPIO Agent built", UVM_MEDIUM)
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    if(is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    
    `uvm_info("GPIO_AGENT_CONNECT", "GPIO Agent connected", UVM_MEDIUM)
  endfunction
  
endclass

// ============================================================================
// UART Agent
// ============================================================================

class uart_agent extends uvm_agent;
  `uvm_component_utils(uart_agent)
  
  uart_sequencer sequencer;
  uart_driver driver;
  uart_monitor monitor;
  
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = uart_monitor::type_id::create("monitor", this);
    
    if(is_active == UVM_ACTIVE) begin
      sequencer = uart_sequencer::type_id::create("sequencer", this);
      driver = uart_driver::type_id::create("driver", this);
    end
    
    `uvm_info("UART_AGENT_BUILD", "UART Agent built", UVM_MEDIUM)
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    if(is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    
    `uvm_info("UART_AGENT_CONNECT", "UART Agent connected", UVM_MEDIUM)
  endfunction
  
endclass

// ============================================================================
// AXI4-Lite Agent
// ============================================================================

class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)
  
  axi_sequencer sequencer;
  axi_driver driver;
  axi_monitor monitor;
  
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = axi_monitor::type_id::create("monitor", this);
    
    if(is_active == UVM_ACTIVE) begin
      sequencer = axi_sequencer::type_id::create("sequencer", this);
      driver = axi_driver::type_id::create("driver", this);
    end
    
    `uvm_info("AXI_AGENT_BUILD", "AXI Agent built", UVM_MEDIUM)
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    if(is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    
    `uvm_info("AXI_AGENT_CONNECT", "AXI Agent connected", UVM_MEDIUM)
  endfunction
  
endclass

// ============================================================================
// Interrupt Agent
// ============================================================================

class interrupt_agent extends uvm_agent;
  `uvm_component_utils(interrupt_agent)
  
  interrupt_sequencer sequencer;
  interrupt_driver driver;
  interrupt_monitor monitor;
  
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = interrupt_monitor::type_id::create("monitor", this);
    
    if(is_active == UVM_ACTIVE) begin
      sequencer = interrupt_sequencer::type_id::create("sequencer", this);
      driver = interrupt_driver::type_id::create("driver", this);
    end
    
    `uvm_info("INT_AGENT_BUILD", "Interrupt Agent built", UVM_MEDIUM)
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    if(is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    
    `uvm_info("INT_AGENT_CONNECT", "Interrupt Agent connected", UVM_MEDIUM)
  endfunction
  
endclass

