class mmu_monitor extends uvm_monitor;
  `uvm_component_utils(mmu_monitor)
  virtual soc_if vif;
  uvm_analysis_port #(mmu_event_seq_item) ap;
  function new(string name, uvm_component parent); super.new(name,parent); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual soc_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","soc_if not found")
  endfunction
  task run_phase(uvm_phase phase);
    mmu_event_seq_item tr;
    forever begin
      @(posedge vif.clk);
      if(vif.hit_pulse || vif.miss_pulse || vif.fault_pulse) begin
        tr=mmu_event_seq_item::type_id::create("mmu_evt",this);
        tr.va=vif.dmem_va; tr.is_write=vif.dmem_we; tr.wdata=vif.dmem_wdata;
        tr.pa=vif.pmem_addr; tr.ready=vif.dmem_ready;
        if(vif.fault_pulse) tr.kind=MMU_FAULT;
        else if(vif.miss_pulse) tr.kind=MMU_MISS;
        else tr.kind=MMU_HIT;
        ap.write(tr);
      end
    end
  endtask
endclass
