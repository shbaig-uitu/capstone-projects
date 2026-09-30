class base_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(base_seq)
  function new(string name="base_seq"); super.new(name); endfunction
  task axi_write(bit [7:0] addr, bit [31:0] data);
    axi_seq_item tr=axi_seq_item::type_id::create("wr");
    start_item(tr); tr.is_write=1; tr.addr=addr; tr.data=data; tr.idle_cycles=0; finish_item(tr);
  endtask
  task axi_read(bit [7:0] addr);
    axi_seq_item tr=axi_seq_item::type_id::create("rd");
    start_item(tr); tr.is_write=0; tr.addr=addr; tr.data=0; tr.idle_cycles=0; finish_item(tr);
  endtask
  task program_page(bit [4:0] vpn, bit [3:0] ppn, bit valid);
    axi_write(8'h00, {22'h0,vpn,ppn,valid});
  endtask
  task clear_fault(); axi_write(8'h04,32'h0); endtask
endclass
