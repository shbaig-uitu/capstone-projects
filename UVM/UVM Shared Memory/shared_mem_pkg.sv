package shared_mem_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "seq_item.sv"
    `include "shared_mem_seq.sv"
    `include "shared_mem_driver.sv"
    `include "shared_mem_monitor.sv"
    `include "shared_mem_scoreboard.sv"
    `include "shared_mem_agent.sv"
    `include "shared_mem_env.sv"
    `include "shared_mem_test.sv"

endpackage
