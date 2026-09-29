#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v vivado >/dev/null 2>&1 || { echo "ERROR: Vivado not found in PATH."; exit 1; }
cd "$ROOT/scripts"
mkdir -p "$ROOT/build"
echo "Building Project 02 for Digilent Arty A7-100T (XC7A100TCSG324-1)"
vivado -mode batch -source vivado_build.tcl -notrace
echo "Bitstream: $ROOT/build/riscv_vga_soc.bit"
