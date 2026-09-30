class riscv_monitor extends uvm_monitor;
  `uvm_component_utils(riscv_monitor)

  virtual riscv_if vif;
  uvm_analysis_port #(seqs_item) item_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_port = new("item_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual riscv_if)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Failed to get vif")
  endfunction

  task run_phase(uvm_phase phase);
    seqs_item item;
    forever begin
      @(posedge vif.clk);
      item = seqs_item::type_id::create("item");
      item.instruct_en = vif.instruct_en;
      item.result      = vif.result;
      item_port.write(item);
      `uvm_info("MON", $sformatf("instruct_en=%0b result=%0h", vif.instruct_en, vif.result), UVM_LOW)
    end
  endtask
endclass
