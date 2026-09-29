#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v iverilog >/dev/null 2>&1 || { echo "ERROR: iverilog not found in PATH."; exit 1; }
command -v vvp >/dev/null 2>&1 || { echo "ERROR: vvp not found in PATH."; exit 1; }
mkdir -p sim/output sim/logs
rm -f sim/output/*.vcd sim/output/*.vvp sim/logs/iverilog_*.log
COMMON=( -g2012 -DSIMULATION rtl/core/rv32i_core.v rtl/peripherals/block_ram.v rtl/peripherals/framebuffer_ram.v rtl/peripherals/duck_animation.v rtl/peripherals/vga_timing.v rtl/peripherals/pixel_address_gen.v rtl/peripherals/rgb_output.v rtl/peripherals/vga_controller.v rtl/peripherals/axi_lite_vga_regs.v rtl/interconnect/mem_interconnect.v rtl/top/riscv_vga_soc.v )
run_one(){ local name="$1" tb="$2"; echo "===== $name ====="; iverilog "${COMMON[@]}" "$tb" -o "sim/output/${name}.vvp"; vvp "sim/output/${name}.vvp" 2>&1 | tee "sim/logs/iverilog_${name}.log"; }
run_one rv32i_core sim/system/tb_rv32i_core.sv
run_one axi_lite_vga_regs sim/system/tb_axi_lite_vga_regs.sv
run_one mem_interconnect sim/system/tb_mem_interconnect.sv
run_one duck_animation sim/system/tb_duck_animation.sv
run_one vga_controller sim/system/tb_vga_controller.sv
run_one riscv_vga_soc sim/system/tb_riscv_vga_soc.sv
if grep -RqsE 'SOC FAIL|VGA FAIL|AXI FAIL|CORE FAIL|ANIM FAIL|FATAL' sim/logs/iverilog_*.log; then echo "Regression failure detected; inspect sim/logs/."; exit 1; fi
echo "Icarus regression complete. VCDs: sim/output/*.vcd"
