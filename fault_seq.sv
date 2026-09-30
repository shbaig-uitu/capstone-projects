class fault_seq extends base_seq;
  `uvm_object_utils(fault_seq)
  function new(string name="fault_seq"); super.new(name); endfunction
  task body();
    // The supplied program intentionally accesses an unmapped VPN.
    // Keep VPN4 invalid and clear status before releasing the core.
    program_page(5'd0,4'd3,1);
    program_page(5'd4,4'd0,0);
    clear_fault();
  endtask
endclass
