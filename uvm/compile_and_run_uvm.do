#!/usr/bin/env tclsh
# RISC-V SoC UVM Testbench Compilation and Execution Script
# File: compile_and_run_uvm.do
# Usage: vsim -do compile_and_run_uvm.do

# ============================================================================
# Compilation Phase
# ============================================================================

echo "============================================================================"
echo "RISC-V SoC UVM Verification - Questa Sim"
echo "============================================================================"
echo ""
echo "[INFO] Starting compilation phase..."
echo ""

# Delete previous work library if it exists
if {[file exists work]} {
  echo "[INFO] Removing previous work library..."
  vdel -all -lib work
}

# Create new work library
vlib work
vmap work work

# ============================================================================
# Compile RTL Files
# ============================================================================

echo "[INFO] Compiling RTL design files..."

# Compile design hierarchy
vlog -sv ../rtl/include/riscv_defines.sv
vlog -sv ../rtl/include/riscv_types.sv
vlog -sv ../rtl/core/rv32i_core.sv
vlog -sv ../rtl/mmu/mmu.sv
vlog -sv ../rtl/mmu/tlb.sv
vlog -sv ../rtl/peripheral/csr_unit.sv
vlog -sv ../rtl/peripheral/exception_handler.sv
vlog -sv ../rtl/memory/sram_sp.sv
vlog -sv ../rtl/top/riscv_soc_top.sv

# ============================================================================
# Compile UVM Testbench
# ============================================================================

echo "[INFO] Compiling UVM verification environment..."

vlog -sv uvm_riscv_if.sv
vlog -sv uvm_riscv_transaction.sv
vlog -sv uvm_pkg.sv
vlog -sv uvm_riscv_sequencer.sv
vlog -sv uvm_riscv_driver.sv
vlog -sv uvm_riscv_monitor.sv
vlog -sv uvm_riscv_agent.sv
vlog -sv uvm_riscv_scoreboard.sv
vlog -sv uvm_riscv_coverage.sv
vlog -sv uvm_riscv_sequences.sv
vlog -sv uvm_riscv_env.sv
vlog -sv uvm_riscv_test.sv
vlog -sv tb_riscv_uvm.sv

echo "[INFO] Compilation phase completed successfully"
echo ""

# ============================================================================
# Simulation Phase
# ============================================================================

echo "============================================================================"
echo "[INFO] Starting simulation phase..."
echo "============================================================================"
echo ""

# Optimize design
vopt -o opt_tb tb_riscv_uvm -debugdb

# Run simulation with verbose output
vsim -debugdb -voptargs="+acc" opt_tb \
    -l uvm_simulation.log \
    -do "run -all; quit"

echo ""
echo "[INFO] Simulation phase completed"
echo "[INFO] Log file: uvm_simulation.log"
echo "[INFO] Waveform file: riscv_uvm.vcd"
echo ""
echo "============================================================================"

# ============================================================================
# Report Generation
# ============================================================================

echo "[INFO] Generating UVM verification report..."

set report_file "uvm_verification_report.txt"
set log_file "uvm_simulation.log"

if {[file exists $log_file]} {
  set fp [open $report_file w]
  
  puts $fp "============================================================================"
  puts $fp "RISC-V SoC UVM Verification Report"
  puts $fp "============================================================================"
  puts $fp ""
  puts $fp "Generated: [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]"
  puts $fp ""
  
  puts $fp "Test Results Summary:"
  puts $fp "====================="
  
  # Read simulation log and extract key information
  set log_fp [open $log_file r]
  set log_content [read $log_fp]
  close $log_fp
  
  # Extract PASS/FAIL information
  if {[string first "ALL TESTS PASSED" $log_content] != -1} {
    puts $fp "Overall Status: PASSED"
  } elseif {[string first "TESTS FAILED" $log_content] != -1} {
    puts $fp "Overall Status: FAILED"
  } else {
    puts $fp "Overall Status: UNKNOWN"
  }
  
  puts $fp ""
  puts $fp "Simulation Log:"
  puts $fp "==============="
  
  # Extract important log lines
  set lines [split $log_content "\n"]
  foreach line $lines {
    if {[string match "*SB_REPORT*" $line] || 
        [string match "*PASS*" $line] || 
        [string match "*FAIL*" $line] ||
        [string match "*TEST*" $line]} {
      puts $fp $line
    }
  }
  
  puts $fp ""
  puts $fp "============================================================================"
  
  close $fp
  echo "[INFO] Report saved to: $report_file"
}

echo ""
echo "============================================================================"
echo "UVM Verification Complete"
echo "============================================================================"
echo ""
echo "Generated files:"
echo "  - work/                    : Compiled design library"
echo "  - riscv_uvm.vcd           : Waveform for GTKWave"
echo "  - uvm_simulation.log      : Detailed simulation log"
echo "  - uvm_verification_report.txt : Summary report"
echo ""

quit

