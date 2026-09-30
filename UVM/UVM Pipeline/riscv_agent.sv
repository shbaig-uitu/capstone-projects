class riscv_agent extends uvm_agent;
  `uvm_component_utils(riscv_agent)

  riscv_driver               driver;
  riscv_monitor              monitor;
  uvm_sequencer #(seqs_item) sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver    = riscv_driver::type_id::create("driver", this);
    monitor   = riscv_monitor::type_id::create("monitor", this);
    sequencer = uvm_sequencer#(seqs_item)::type_id::create("sequencer", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // driver ko sequencer se connect karo
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass
