`ifndef SYSTOLIC_PKG_SV
`define SYSTOLIC_PKG_SV

package systolic_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "systolic_seq_item.sv"
  `include "systolic_driver.sv"
  `include "systolic_monitor.sv"  
  `include "systolic_coverage.sv"
  `include "systolic_scoreboard.sv"
  `include "systolic_agent.sv"       
  `include "systolic_env.sv"         
  `include "systolic_sequence.sv"   
  `include "systolic_test.sv"
endpackage

`endif
