typedef enum bit [1:0] {MMU_HIT, MMU_MISS, MMU_FAULT} mmu_event_kind_e;
class mmu_event_seq_item extends uvm_sequence_item;
  mmu_event_kind_e kind;
  bit [12:0] va;
  bit is_write;
  bit [31:0] wdata;
  bit [11:0] pa;
  bit ready;
  `uvm_object_utils_begin(mmu_event_seq_item)
    `uvm_field_enum(mmu_event_kind_e, kind, UVM_ALL_ON)
    `uvm_field_int(va, UVM_ALL_ON)
    `uvm_field_int(is_write, UVM_ALL_ON)
    `uvm_field_int(wdata, UVM_ALL_ON)
    `uvm_field_int(pa, UVM_ALL_ON)
    `uvm_field_int(ready, UVM_ALL_ON)
  `uvm_object_utils_end
  function new(string name="mmu_event_seq_item"); super.new(name); endfunction
endclass
