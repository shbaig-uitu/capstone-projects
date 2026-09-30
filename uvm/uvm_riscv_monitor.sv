/**
 * RISC-V SoC UVM Monitor
 * 
 * File: uvm_riscv_monitor.sv
 * Description: UVM monitors for capturing DUT behavior
 */

// ============================================================================
// GPIO Monitor
// ============================================================================

class gpio_monitor extends uvm_monitor;
  `uvm_component_utils(gpio_monitor)
  
  virtual riscv_soc_if vif;
  uvm_analysis_port #(gpio_transaction) ap;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("GPIO_MON_BUILD", "Virtual interface not found")
    
    `uvm_info("GPIO_MON_BUILD", "GPIO Monitor built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      @(posedge vif.clk);
      
      gpio_transaction trans = gpio_transaction::type_id::create("trans");
      trans.gpio_in = vif.gpio_in;
      trans.gpio_out = vif.gpio_out;
      trans.gpio_expected = vif.gpio_in;  // Expected is same as input for pass-through
      
      ap.write(trans);
      
      `uvm_info("GPIO_MON", $sformatf("Monitored %s", trans.convert2string()), UVM_HIGH)
    end
  endtask
  
endclass

// ============================================================================
// UART Monitor
// ============================================================================

class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)
  
  virtual riscv_soc_if vif;
  uvm_analysis_port #(uart_transaction) ap;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("UART_MON_BUILD", "Virtual interface not found")
    
    `uvm_info("UART_MON_BUILD", "UART Monitor built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      @(posedge vif.clk);
      
      uart_transaction trans = uart_transaction::type_id::create("trans");
      trans.uart_rx = vif.uart_rx;
      trans.uart_tx = vif.uart_tx;
      trans.uart_expected = vif.uart_rx;  // Expected is RX echoed to TX
      
      ap.write(trans);
      
      `uvm_info("UART_MON", $sformatf("Monitored %s", trans.convert2string()), UVM_HIGH)
    end
  endtask
  
endclass

// ============================================================================
// AXI4-Lite Monitor
// ============================================================================

class axi_monitor extends uvm_monitor;
  `uvm_component_utils(axi_monitor)
  
  virtual riscv_soc_if vif;
  uvm_analysis_port #(axi_transaction) ap;
  
  logic [31:0] current_addr;
  logic [31:0] current_data;
  logic [3:0]  current_strb;
  logic        write_in_progress;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
    write_in_progress = 1'b0;
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("AXI_MON_BUILD", "Virtual interface not found")
    
    `uvm_info("AXI_MON_BUILD", "AXI Monitor built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    fork
      monitor_write_transactions();
      monitor_read_transactions();
    join
  endtask
  
  task monitor_write_transactions();
    forever begin
      // Wait for write address valid
      @(posedge vif.clk);
      if(vif.axi_awvalid && vif.axi_awready) begin
        current_addr = vif.axi_awaddr;
        write_in_progress = 1'b1;
        
        // Wait for write data valid
        forever begin
          @(posedge vif.clk);
          if(vif.axi_wvalid && vif.axi_wready) begin
            current_data = vif.axi_wdata;
            current_strb = vif.axi_wstrb;
            
            axi_transaction trans = axi_transaction::type_id::create("trans");
            trans.trans_type = AXI_WRITE;
            trans.addr = current_addr;
            trans.data = current_data;
            trans.strb = current_strb;
            
            // Wait for write response
            forever begin
              @(posedge vif.clk);
              if(vif.axi_bvalid && vif.axi_bready) begin
                trans.resp = vif.axi_bresp;
                ap.write(trans);
                `uvm_info("AXI_MON", $sformatf("Write monitored %s", trans.convert2string()), UVM_HIGH)
                write_in_progress = 1'b0;
                break;
              end
            end
            break;
          end
        end
      end
    end
  endtask
  
  task monitor_read_transactions();
    forever begin
      // Wait for read address valid
      @(posedge vif.clk);
      if(vif.axi_arvalid && vif.axi_arready) begin
        current_addr = vif.axi_araddr;
        
        // Wait for read data valid
        forever begin
          @(posedge vif.clk);
          if(vif.axi_rvalid && vif.axi_rready) begin
            axi_transaction trans = axi_transaction::type_id::create("trans");
            trans.trans_type = AXI_READ;
            trans.addr = current_addr;
            trans.data = vif.axi_rdata;
            trans.resp = vif.axi_rresp;
            
            ap.write(trans);
            `uvm_info("AXI_MON", $sformatf("Read monitored %s", trans.convert2string()), UVM_HIGH)
            break;
          end
        end
      end
    end
  endtask
  
endclass

// ============================================================================
// Interrupt Monitor
// ============================================================================

class interrupt_monitor extends uvm_monitor;
  `uvm_component_utils(interrupt_monitor)
  
  virtual riscv_soc_if vif;
  uvm_analysis_port #(interrupt_transaction) ap;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("INT_MON_BUILD", "Virtual interface not found")
    
    `uvm_info("INT_MON_BUILD", "Interrupt Monitor built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      @(posedge vif.clk);
      
      if(vif.ext_interrupt) begin
        interrupt_transaction trans = interrupt_transaction::type_id::create("trans");
        trans.ext_interrupt = vif.ext_interrupt;
        trans.delay_cycles = 0;
        
        ap.write(trans);
        
        `uvm_info("INT_MON", $sformatf("Monitored %s", trans.convert2string()), UVM_HIGH)
      end
    end
  endtask
  
endclass

