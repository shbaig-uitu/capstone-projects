#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
command -v openroad >/dev/null 2>&1 || { echo "ERROR: openroad not found in PATH."; exit 1; }
[ -f build_asic/riscv_vga_soc.v ] || { echo "ERROR: run 'make asic' first."; exit 1; }
: "${PDK_ROOT:?Set PDK_ROOT}"
: "${TECH_LEF:?Set TECH_LEF}"
: "${STD_CELL_LEF:?Set STD_CELL_LEF}"
: "${STD_CELL_LIB:?Set STD_CELL_LIB}"
export TOP="${TOP:-riscv_vga_soc}"
export NETLIST="${NETLIST:-../../build_asic/riscv_vga_soc.v}"
export SDC="${SDC:-top.sdc}"
export REPORT_DIR="${REPORT_DIR:-../reports}"
mkdir -p physical_design/reports
openroad -no_splash -exit physical_design/openroad/run_openroad.tcl | tee physical_design/reports/openroad_console.log
