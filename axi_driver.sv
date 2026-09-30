class axi_driver extends uvm_driver #(axi_seq_item);
  `uvm_component_utils(axi_driver)
  virtual soc_if vif;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual soc_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","soc_if not found")
  endfunction

  task reset_bus();
    vif.axi_awvalid <= 0; vif.axi_wvalid <= 0; vif.axi_bready <= 0;
    vif.axi_arvalid <= 0; vif.axi_rready <= 0;
  endtask

  task drive_write(axi_seq_item tr);
    @(posedge vif.clk);
    vif.axi_awaddr <= tr.addr; vif.axi_awvalid <= 1;
    vif.axi_wdata <= tr.data; vif.axi_wvalid <= 1; vif.axi_bready <= 1;
    do @(posedge vif.clk); while (!(vif.axi_awready && vif.axi_wready));
    vif.axi_awvalid <= 0; vif.axi_wvalid <= 0;
    do @(posedge vif.clk); while (!vif.axi_bvalid);
    @(posedge vif.clk);
    vif.axi_bready <= 0;
  endtask

  task drive_read(axi_seq_item tr);
    @(posedge vif.clk);
    vif.axi_araddr <= tr.addr; vif.axi_arvalid <= 1; vif.axi_rready <= 1;
    do @(posedge vif.clk); while (!vif.axi_arready);
    vif.axi_arvalid <= 0;
    do @(posedge vif.clk); while (!vif.axi_rvalid);
    @(posedge vif.clk);
    vif.axi_rready <= 0;
  endtask

  task run_phase(uvm_phase phase);
    axi_seq_item tr;
    reset_bus();
    forever begin
      seq_item_port.get_next_item(tr);
      repeat(tr.idle_cycles) @(posedge vif.clk);
      if(tr.is_write) drive_write(tr); else drive_read(tr);
      seq_item_port.item_done();
    end
  endtask
endclass
