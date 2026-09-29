#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=== Project 02 audit ==="

echo "Root: $ROOT"

echo "Target FPGA: Arty A7-100T / XC7A100TCSG324-1"

echo

echo "Required RTL files:"
for f in \
  rtl/core/rv32i_core.v \
  rtl/interconnect/mem_interconnect.v \
  rtl/peripherals/block_ram.v \
  rtl/peripherals/framebuffer_ram.v \
  rtl/peripherals/vga_timing.v \
  rtl/peripherals/pixel_address_gen.v \
  rtl/peripherals/vga_controller.v \
  rtl/peripherals/rgb_output.v \
  rtl/peripherals/axi_lite_vga_regs.v \
  rtl/peripherals/duck_animation.v \
  rtl/top/riscv_vga_soc.v \
  rtl/top/arty_a7_100t_vga_top.v \
  constraints/pins/arty_a7_100t_pmod_vga.xdc \
  constraints/timing/arty_a7_100t_timing.xdc \
  firmware/firmware.hex; do
  test -f "$f" && echo "  OK   $f" || { echo "  MISS $f"; exit 1; }
done

echo
echo "Tools:"
for t in iverilog vvp gtkwave yosys verilator vivado vsim; do
  if command -v "$t" >/dev/null 2>&1; then
    echo "  YES  $t"
  else
    echo "  --   $t"
  fi
done

echo
echo "Stale PYNQ/GPU artifact scan:"
if grep -RniE 'pynq_z2|gpu_accelerator|gpu_driver|riscv_gpu_soc|GPU Accelerator' \
    --exclude-dir=.git --exclude='*.md' --exclude='project_audit.sh' . >/tmp/project02_stale_refs.txt 2>/dev/null; then
  cat /tmp/project02_stale_refs.txt
  echo "WARNING: stale design references remain."
else
  echo "  PASS — no obsolete design-path references found."
fi

echo
echo "Audit complete. Missing tools do not imply a design failure; they only mean that stage cannot be executed on this machine yet."
