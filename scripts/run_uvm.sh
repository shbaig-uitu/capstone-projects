#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v vsim >/dev/null 2>&1 || { echo "ERROR: Questa/ModelSim 'vsim' not found."; exit 1; }
mkdir -p uvm/reports
vsim -c -do uvm/run_uvm.do | tee uvm/reports/uvm_run.log
if command -v vcover >/dev/null 2>&1 && [ -f uvm/uvm_coverage.ucdb ]; then
  vcover report -details -annotate -output uvm/reports/coverage.txt uvm/uvm_coverage.ucdb || true
fi
