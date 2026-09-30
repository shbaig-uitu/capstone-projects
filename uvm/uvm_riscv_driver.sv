/**
 * RISC-V SoC UVM Driver
 * 
 * File: uvm_riscv_driver.sv
 * Description: UVM drivers for stimulus generation
 */

// ============================================================================
// GPIO Driver
// ============================================================================

class gpio_driver extends uvm_driver #(gpio_transaction);
  `uvm_component_utils(gpio_driver)
  
  virtual riscv_soc_if vif;
  gpio_transaction trans;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("GPIO_DRV_BUILD", "Virtual interface not found")
    
    `uvm_info("GPIO_DRV_BUILD", "GPIO Driver built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      seq_item_port.get_next_item(trans);
      
      @(posedge vif.clk);
      vif.gpio_in <= trans.gpio_in;
      
      `uvm_info("GPIO_DRV", $sformatf("Driving %s", trans.convert2string()), UVM_HIGH)
      
      seq_item_port.item_done();
    end
  endtask
  
endclass

// ============================================================================
// UART Driver
// ============================================================================

class uart_driver extends uvm_driver #(uart_transaction);
  `uvm_component_utils(uart_driver)
  
  virtual riscv_soc_if vif;
  uart_transaction trans;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("UART_DRV_BUILD", "Virtual interface not found")
    
    `uvm_info("UART_DRV_BUILD", "UART Driver built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      seq_item_port.get_next_item(trans);
      
      @(posedge vif.clk);
      vif.uart_rx <= trans.uart_rx;
      
      `uvm_info("UART_DRV", $sformatf("Driving %s", trans.convert2string()), UVM_HIGH)
      
      seq_item_port.item_done();
    end
  endtask
  
endclass

// ============================================================================
// AXI4-Lite Driver
// ============================================================================

class axi_driver extends uvm_driver #(axi_transaction);
  `uvm_component_utils(axi_driver)
  
  virtual riscv_soc_if vif;
  axi_transaction trans;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("AXI_DRV_BUILD", "Virtual interface not found")
    
    `uvm_info("AXI_DRV_BUILD", "AXI Driver built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      seq_item_port.get_next_item(trans);
      
      if(trans.trans_type == AXI_WRITE) begin
        write_transaction(trans);
      end else begin
        read_transaction(trans);
      end
      
      `uvm_info("AXI_DRV", $sformatf("Driving %s", trans.convert2string()), UVM_HIGH)
      
      seq_item_port.item_done();
    end
  endtask
  
  task write_transaction(axi_transaction trans);
    // Write Address Channel
    @(posedge vif.clk);
    vif.axi_awaddr <= trans.addr;
    vif.axi_awvalid <= 1'b1;
    
    while(!vif.axi_awready) @(posedge vif.clk);
    @(posedge vif.clk);
    vif.axi_awvalid <= 1'b0;
    
    // Write Data Channel
    @(posedge vif.clk);
    vif.axi_wdata <= trans.data;
    vif.axi_wstrb <= trans.strb;
    vif.axi_wvalid <= 1'b1;
    
    while(!vif.axi_wready) @(posedge vif.clk);
    @(posedge vif.clk);
    vif.axi_wvalid <= 1'b0;
    
    // Write Response Channel
    @(posedge vif.clk);
    vif.axi_bready <= 1'b1;
    while(!vif.axi_bvalid) @(posedge vif.clk);
    trans.resp = vif.axi_bresp;
    @(posedge vif.clk);
    vif.axi_bready <= 1'b0;
  endtask
  
  task read_transaction(axi_transaction trans);
    // Read Address Channel
    @(posedge vif.clk);
    vif.axi_araddr <= trans.addr;
    vif.axi_arvalid <= 1'b1;
    
    while(!vif.axi_arready) @(posedge vif.clk);
    @(posedge vif.clk);
    vif.axi_arvalid <= 1'b0;
    
    // Read Data Channel
    @(posedge vif.clk);
    vif.axi_rready <= 1'b1;
    while(!vif.axi_rvalid) @(posedge vif.clk);
    trans.data = vif.axi_rdata;
    trans.resp = vif.axi_rresp;
    @(posedge vif.clk);
    vif.axi_rready <= 1'b0;
  endtask
  
endclass

// ============================================================================
// Interrupt Driver
// ============================================================================

class interrupt_driver extends uvm_driver #(interrupt_transaction);
  `uvm_component_utils(interrupt_driver)
  
  virtual riscv_soc_if vif;
  interrupt_transaction trans;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("INT_DRV_BUILD", "Virtual interface not found")
    
    `uvm_info("INT_DRV_BUILD", "Interrupt Driver built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      seq_item_port.get_next_item(trans);
      
      repeat(trans.delay_cycles) @(posedge vif.clk);
      
      @(posedge vif.clk);
      vif.ext_interrupt <= trans.ext_interrupt;
      
      `uvm_info("INT_DRV", $sformatf("Driving %s", trans.convert2string()), UVM_HIGH)
      
      seq_item_port.item_done();
    end
  endtask
  
endclass

