#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v iverilog >/dev/null 2>&1 || { echo "ERROR: iverilog not found. Install it with: sudo apt install iverilog"; exit 1; }
command -v vvp >/dev/null 2>&1 || { echo "ERROR: vvp not found. Install it with: sudo apt install iverilog"; exit 1; }
mkdir -p sim/output sim/logs evidence/frames
rm -f sim/output/frame_*.ppm evidence/frames/frame_*.png sim/output/vga_frame_capture.vvp

echo "Building accelerated VGA visual-capture test..."
iverilog -g2012 -DSIMULATION \
  rtl/peripherals/duck_animation.v \
  rtl/peripherals/vga_timing.v \
  rtl/peripherals/pixel_address_gen.v \
  rtl/peripherals/rgb_output.v \
  rtl/peripherals/vga_controller.v \
  sim/visual/tb_vga_frame_capture.sv \
  -o sim/output/vga_frame_capture.vvp

echo "Running capture (1 MHz simulation clock; raster remains 640x480)..."
vvp sim/output/vga_frame_capture.vvp | tee sim/logs/vga_frame_capture.log

test "$(find sim/output -maxdepth 1 -name 'frame_*.ppm' | wc -l)" -eq 50
python3 scripts/ppm_to_png.py sim/output evidence/frames

echo
echo "Frame evidence written to evidence/frames/"
ls -lh evidence/frames/frame_*.png
