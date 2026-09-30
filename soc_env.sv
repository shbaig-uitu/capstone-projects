class soc_env extends uvm_env;
  `uvm_component_utils(soc_env)
  axi_agent axi; mmu_agent mmu; soc_scoreboard sb; soc_coverage cov;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi=axi_agent::type_id::create("axi",this);
    mmu=mmu_agent::type_id::create("mmu",this);
    sb=soc_scoreboard::type_id::create("sb",this);
    cov=soc_coverage::type_id::create("cov",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    mmu.mon.ap.connect(sb.mmu_imp);
    mmu.mon.ap.connect(cov.analysis_export);
  endfunction
endclass
