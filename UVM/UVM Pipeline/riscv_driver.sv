class riscv_driver extends uvm_driver #(seqs_item);
  `uvm_component_utils(riscv_driver)

  virtual riscv_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual riscv_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRIVER", "Failed to get vif")
  endfunction

  task run_phase(uvm_phase phase);
    seqs_item req;

    // --- Reset ---
    vif.instruct_en = 1'b0;
    vif.instruction = 32'h0;
    repeat (2) @(posedge vif.clk);

    // --- Main driving loop: sequencer se transactions lo aur DUT ko do ---
    forever begin
      seq_item_port.get_next_item(req);
      @(posedge vif.clk);
      vif.instruct_en <= req.instruct_en;
      vif.instruction <= req.instruction;
      seq_item_port.item_done();
    end
  endtask
endclass

