#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "Project 02 — RV32I + VGA / Arty A7-100T"
./scripts/project_audit.sh
make test
if command -v gtkwave >/dev/null 2>&1; then
  echo "Open waveform with: gtkwave sim/output/riscv_vga_soc.vcd"
else
  echo "GTKWave not installed; VCDs are in sim/output/"
fi
