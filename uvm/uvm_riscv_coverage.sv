/**
 * RISC-V SoC UVM Functional Coverage
 * 
 * File: uvm_riscv_coverage.sv
 * Description: Functional coverage collectors for verification completeness
 */

// ============================================================================
// GPIO Coverage
// ============================================================================

class gpio_coverage extends uvm_component;
  `uvm_component_utils(gpio_coverage)
  
  virtual riscv_soc_if vif;
  
  covergroup gpio_coverage_group;
    gpio_in_coverage: coverpoint vif.gpio_in {
      bins low = {8'h00};
      bins mid_low = {[8'h01:8'h7F]};
      bins mid_high = {[8'h80:8'hFE]};
      bins high = {8'hFF};
      bins special_aa = {8'hAA};
      bins special_55 = {8'h55};
    }
    gpio_out_coverage: coverpoint vif.gpio_out {
      bins low = {8'h00};
      bins mid_low = {[8'h01:8'h7F]};
      bins mid_high = {[8'h80:8'hFE]};
      bins high = {8'hFF};
      bins special_aa = {8'hAA};
      bins special_55 = {8'h55};
    }
    gpio_correlation: cross gpio_in_coverage, gpio_out_coverage {
      ignore_bins pass_through = binsof(gpio_in_coverage) == binsof(gpio_out_coverage);
    }
  endgroup
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    gpio_coverage_group = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("GPIO_COV_BUILD", "Virtual interface not found")
    
    `uvm_info("GPIO_COV_BUILD", "GPIO Coverage built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      @(posedge vif.clk);
      gpio_coverage_group.sample();
    end
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("GPIO_COV_REPORT", $sformatf("GPIO Coverage = %0.2f%%", 
              gpio_coverage_group.get_coverage()), UVM_LOW)
  endfunction
  
endclass

// ============================================================================
// UART Coverage
// ============================================================================

class uart_coverage extends uvm_component;
  `uvm_component_utils(uart_coverage)
  
  virtual riscv_soc_if vif;
  
  covergroup uart_coverage_group;
    uart_rx_coverage: coverpoint vif.uart_rx {
      bins low = {1'b0};
      bins high = {1'b1};
    }
    uart_tx_coverage: coverpoint vif.uart_tx {
      bins low = {1'b0};
      bins high = {1'b1};
    }
    uart_correlation: cross uart_rx_coverage, uart_tx_coverage;
  endgroup
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    uart_coverage_group = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("UART_COV_BUILD", "Virtual interface not found")
    
    `uvm_info("UART_COV_BUILD", "UART Coverage built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      @(posedge vif.clk);
      uart_coverage_group.sample();
    end
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("UART_COV_REPORT", $sformatf("UART Coverage = %0.2f%%",
              uart_coverage_group.get_coverage()), UVM_LOW)
  endfunction
  
endclass

// ============================================================================
// AXI Coverage
// ============================================================================

class axi_coverage extends uvm_component;
  `uvm_component_utils(axi_coverage)
  
  virtual riscv_soc_if vif;
  
  covergroup axi_coverage_group;
    axi_write_addr: coverpoint vif.axi_awaddr {
      bins low = {[32'h00000000:32'h0000FFFF]};
      bins mid = {[32'h80000000:32'h8000FFFF]};
      wildcard bins other = {32'hxxxxxxxx};
    }
    axi_read_addr: coverpoint vif.axi_araddr {
      bins low = {[32'h00000000:32'h0000FFFF]};
      bins mid = {[32'h80000000:32'h8000FFFF]};
      wildcard bins other = {32'hxxxxxxxx};
    }
    axi_write_data: coverpoint vif.axi_wdata {
      bins low = {[32'h00000000:32'h0000FFFF]};
      bins high = {[32'hFFFF0000:32'hFFFFFFFF]};
      wildcard bins other = {32'hxxxxxxxx};
    }
    axi_read_data: coverpoint vif.axi_rdata {
      bins low = {[32'h00000000:32'h0000FFFF]};
      bins high = {[32'hFFFF0000:32'hFFFFFFFF]};
      wildcard bins other = {32'hxxxxxxxx};
    }
  endgroup
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    axi_coverage_group = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual riscv_soc_if)::get(this, "", "vif", vif))
      `uvm_fatal("AXI_COV_BUILD", "Virtual interface not found")
    
    `uvm_info("AXI_COV_BUILD", "AXI Coverage built", UVM_MEDIUM)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      @(posedge vif.clk);
      axi_coverage_group.sample();
    end
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("AXI_COV_REPORT", $sformatf("AXI Coverage = %0.2f%%",
              axi_coverage_group.get_coverage()), UVM_LOW)
  endfunction
  
endclass

