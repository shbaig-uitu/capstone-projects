class page_table_prog_seq extends base_seq;
  `uvm_object_utils(page_table_prog_seq)
  function new(string name="page_table_prog_seq"); super.new(name); endfunction
  task body();
    program_page(5'd0,4'd3,1);
    program_page(5'd4,4'd0,0);
    clear_fault();
  endtask
endclass
