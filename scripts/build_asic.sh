#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v yosys >/dev/null 2>&1 || {
  echo "ERROR: yosys not found in PATH."
  exit 1
}

mkdir -p "$ROOT/build_asic"
cd "$ROOT"
yosys physical_design/synth_asic.ys

echo "ASIC netlist: $ROOT/build_asic/riscv_vga_soc.v"
