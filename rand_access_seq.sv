class rand_access_seq extends base_seq;
  `uvm_object_utils(rand_access_seq)
  rand bit [4:0] vpn;
  rand bit [3:0] ppn;
  rand bit valid;
  constraint c { vpn inside {[0:31]}; ppn inside {[0:15]}; }
  function new(string name="rand_access_seq"); super.new(name); endfunction
  task body();
    repeat(8) begin
      if(!randomize()) `uvm_fatal("RAND","randomization failed");
      program_page(vpn,ppn,valid);
    end
    clear_fault();
  endtask
endclass
