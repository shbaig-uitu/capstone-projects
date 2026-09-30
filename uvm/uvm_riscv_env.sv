/**
 * RISC-V SoC UVM Environment
 * 
 * File: uvm_riscv_env.sv
 * Description: UVM environment that instantiates all agents and scoreboards
 */

class riscv_uvm_env extends uvm_env;
  `uvm_component_utils(riscv_uvm_env)
  
  // Agents
  gpio_agent gpio_agt;
  uart_agent uart_agt;
  axi_agent axi_agt;
  interrupt_agent int_agt;
  
  // Scoreboards
  top_scoreboard sb;
  
  // Coverage
  gpio_coverage gpio_cov;
  uart_coverage uart_cov;
  axi_coverage axi_cov;
  
  virtual riscv_soc_if vif;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Get virtual interface
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("ENV_BUILD", "Virtual interface not found")
    
    // Set interface for agents
    uvm_config_db #(virtual riscv_soc_if)::set(this, "*", "vif", vif);
    
    // Instantiate agents
    gpio_agt = gpio_agent::type_id::create("gpio_agt", this);
    uart_agt = uart_agent::type_id::create("uart_agt", this);
    axi_agt = axi_agent::type_id::create("axi_agt", this);
    int_agt = interrupt_agent::type_id::create("int_agt", this);
    
    // Instantiate scoreboards
    sb = top_scoreboard::type_id::create("sb", this);
    
    // Instantiate coverage
    gpio_cov = gpio_coverage::type_id::create("gpio_cov", this);
    uart_cov = uart_coverage::type_id::create("uart_cov", this);
    axi_cov = axi_coverage::type_id::create("axi_cov", this);
    
    `uvm_info("ENV_BUILD", "Environment built successfully", UVM_MEDIUM)
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Connect GPIO monitor to scoreboard
    gpio_agt.monitor.ap.connect(sb.gpio_sb.ap);
    
    // Connect UART monitor to scoreboard
    uart_agt.monitor.ap.connect(sb.uart_sb.ap);
    
    // Connect AXI monitor to scoreboard
    axi_agt.monitor.ap.connect(sb.axi_sb.ap);
    
    `uvm_info("ENV_CONNECT", "Environment connected successfully", UVM_MEDIUM)
  endfunction
  
endclass

