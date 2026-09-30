class soc_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(soc_scoreboard)
  uvm_analysis_imp #(mmu_event_seq_item, soc_scoreboard) mmu_imp;
  int unsigned hits, misses, faults, errors;
  bit miss_pending;
  function new(string name, uvm_component parent);
    super.new(name,parent); mmu_imp=new("mmu_imp",this);
  endfunction
  function void write(mmu_event_seq_item tr);
    case(tr.kind)
      MMU_HIT: begin
        hits++;
        if(!tr.ready) begin errors++; `uvm_error("MMU","TLB hit did not complete access") end
      end
      MMU_MISS: begin
        misses++; miss_pending=1;
      end
      MMU_FAULT: begin
        faults++;
        if(!miss_pending) begin
          errors++; `uvm_error("MMU","Page fault observed without a preceding TLB miss")
        end
        miss_pending=0;
        if(!tr.ready) begin errors++; `uvm_error("MMU","Fault did not complete the access") end
      end
    endcase
  endfunction
  function void report_phase(uvm_phase phase);
    `uvm_info("SCOREBOARD",$sformatf("hits=%0d misses=%0d faults=%0d errors=%0d",hits,misses,faults,errors),UVM_LOW)
    if(errors==0) begin
  `uvm_info("SCOREBOARD","MMU event checks PASSED",UVM_NONE)
end else begin
  `uvm_error("SCOREBOARD","MMU event checks FAILED")
end
  endfunction
endclass
