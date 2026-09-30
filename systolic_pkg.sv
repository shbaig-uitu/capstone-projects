
package systolic_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    `include "axi_seq_item.sv"
    `include "axi_driver.sv"
    `include "axi_monitor.sv"
    `include "systolic_coverage.sv"
    `include "systolic_scoreboard.sv"
    `include "systolic_agent.sv"
    `include "systolic_sequence.sv"
    `include "systolic_env.sv"
    `include "systolic_base_test.sv"
endpackage