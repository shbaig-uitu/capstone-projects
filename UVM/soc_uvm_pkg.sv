package soc_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "core_transaction_uvm.sv"
    `include "core_sequence_uvm.sv"
    `include "core_driver_uvm.sv"
    `include "core_monitor_uvm.sv"
    `include "core_agent_uvm.sv"
    `include "soc_scoreboard_uvm.sv"
    `include "soc_env_uvm.sv"
    `include "shared_memory_test_uvm.sv"
    `include "arbitration_test_uvm.sv"
    `include "full_system_test_uvm.sv"

endpackage