class soc_coverage extends uvm_subscriber #(mmu_event_seq_item);
  `uvm_component_utils(soc_coverage)
  mmu_event_seq_item tr;
  covergroup mmu_cg;
    cp_kind: coverpoint tr.kind { bins hit={MMU_HIT}; bins miss={MMU_MISS}; bins fault={MMU_FAULT}; }
    cp_access: coverpoint tr.is_write { bins read={0}; bins write={1}; }
    cp_vpn: coverpoint tr.va[12:8] { bins low={[0:7]}; bins mid={[8:23]}; bins high={[24:31]}; }
    cross_kind_access: cross cp_kind, cp_access;
  endgroup
  function new(string name, uvm_component parent);
    super.new(name,parent); mmu_cg=new;
  endfunction
  function void write(mmu_event_seq_item t); tr=t; mmu_cg.sample(); endfunction
  function void report_phase(uvm_phase phase);
    `uvm_info("COVERAGE",$sformatf("MMU functional coverage=%0.2f%%",mmu_cg.get_coverage()),UVM_NONE)
  endfunction
endclass
