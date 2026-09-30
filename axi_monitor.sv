class axi_monitor extends uvm_monitor;
  `uvm_component_utils(axi_monitor)
  virtual soc_if vif;
  uvm_analysis_port #(axi_seq_item) ap;
  function new(string name, uvm_component parent); super.new(name,parent); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual soc_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","soc_if not found")
  endfunction
  task run_phase(uvm_phase phase);
    axi_seq_item tr;
    forever begin
      @(posedge vif.clk);
      if(vif.axi_awvalid && vif.axi_awready && vif.axi_wvalid && vif.axi_wready) begin
        tr=axi_seq_item::type_id::create("wr",this);
        tr.is_write=1; tr.addr=vif.axi_awaddr; tr.data=vif.axi_wdata; ap.write(tr);
      end
      if(vif.axi_arvalid && vif.axi_arready) begin
        tr=axi_seq_item::type_id::create("rd",this);
        tr.is_write=0; tr.addr=vif.axi_araddr; tr.data='0; ap.write(tr);
      end
    end
  endtask
endclass
