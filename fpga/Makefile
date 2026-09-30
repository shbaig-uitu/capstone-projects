#############################################################################
# RISC-V SoC with Virtual Memory Support - Capstone Project
#
# File: Makefile
# Device: Xilinx Artix-7 A7-100T (XC7A100TCSG324-1)
# Board: Digilent Arty A7-100T
#
# Description: Build automation for FPGA implementation on Arty100T
#              Complete flow: RTL synthesis, place & route, bitstream generation,
#              and FPGA programming
#############################################################################

.PHONY: all build synth impl bitstream clean help check program report-timing report-utilization
.NOTPARALLEL:

#############################################################################
# Configuration Variables
#############################################################################

# Vivado installation and execution
VIVADO ?= vivado
VIVADO_FLAGS := -mode batch
VIVADO_SCRIPT_SYNTH := vivado_synth.tcl
VIVADO_SCRIPT_IMPL := vivado_impl.tcl
VIVADO_SCRIPT_BUILD := vivado_build.tcl
VIVADO_SCRIPT_PROG := vivado_program.tcl

# Project settings
PROJECT_NAME := riscv_soc_arty
PART := xc7a100tcsg324-1
BOARD := arty_a7-100
DEVICE := xc7a100t

# Directory structure
BUILD_DIR := ./build
SYNTH_DIR := $(BUILD_DIR)/synth
IMPL_DIR := $(BUILD_DIR)/impl
BIT_DIR := ./bitstream
REPORTS_DIR := $(BIT_DIR)/reports
SCRIPT_DIR := ./scripts
RTL_DIR := ../rtl
CONSTRAINT_FILE := ./arty100t.xdc

# Output files
SYNTH_CHECKPOINT := $(SYNTH_DIR)/$(PROJECT_NAME)_synth.dcp
IMPL_CHECKPOINT := $(IMPL_DIR)/$(PROJECT_NAME)_impl.dcp
BITSTREAM := $(BIT_DIR)/$(PROJECT_NAME).bit
BITSTREAM_LTXFILE := $(BIT_DIR)/$(PROJECT_NAME).ltx

# FPGA programming
SERIAL_PORT ?= /dev/ttyUSB0
BAUD_RATE := 115200

#############################################################################
# Default Target - Help
#############################################################################

.DEFAULT_GOAL := help

help:
	@echo ""
	@echo "=============================================================="
	@echo "RISC-V SoC FPGA Build System - Arty A7-100T"
	@echo "Device: XC7A100TCSG324-1"
	@echo "=============================================================="
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "PRIMARY TARGETS:"
	@echo "  make build          - Complete build (synth + impl + bitstream)"
	@echo "  make synth          - Run synthesis only"
	@echo "  make impl           - Run place & route only (requires synth)"
	@echo "  make bitstream      - Generate bitstream (requires impl)"
	@echo "  make program        - Program FPGA with bitstream"
	@echo ""
	@echo "VERIFICATION TARGETS:"
	@echo "  make check          - Verify Vivado installation"
	@echo "  make status         - Show build status"
	@echo "  make report-timing  - Generate timing report"
	@echo "  make report-util    - Generate utilization report"
	@echo ""
	@echo "CLEANUP TARGETS:"
	@echo "  make clean          - Remove build artifacts"
	@echo "  make distclean       - Remove all generated files"
	@echo ""
	@echo "VARIABLES:"
	@echo "  VIVADO=<path>       - Path to Vivado (default: vivado)"
	@echo "  SERIAL_PORT=<port>  - Serial port for programming"
	@echo "  PART=<part>         - FPGA part (default: xc7a100tcsg324-1)"
	@echo ""
	@echo "EXAMPLES:"
	@echo "  make build                           # Full build"
	@echo "  make build VIVADO=/opt/Xilinx/Vivado/2021.2/bin/vivado"
	@echo "  make program SERIAL_PORT=/dev/ttyUSB0"
	@echo ""

#############################################################################
# Pre-build Checks
#############################################################################

check:
	@echo "Checking Vivado installation..."
	@which $(VIVADO) > /dev/null 2>&1 || { echo "ERROR: Vivado not found in PATH"; exit 1; }
	@echo "✓ Vivado found: $$(which $(VIVADO))"
	@$(VIVADO) -version 2>&1 | head -1
	@echo "✓ RTL directory exists: $(RTL_DIR)"
	@test -d $(RTL_DIR) || { echo "ERROR: RTL directory not found"; exit 1; }
	@echo "✓ Constraints file exists: $(CONSTRAINT_FILE)"
	@test -f $(CONSTRAINT_FILE) || { echo "ERROR: Constraints file not found"; exit 1; }
	@echo "✓ All checks passed!"

#############################################################################
# Main Build Targets
#############################################################################

# Complete build flow
all: build

build: check $(BITSTREAM)
	@echo ""
	@echo "=============================================================="
	@echo "✓ FPGA Build Complete!"
	@echo "  Bitstream: $(BITSTREAM)"
	@echo "  Size: $$(du -h $(BITSTREAM) | cut -f1)"
	@echo "=============================================================="
	@echo ""

# Synthesis target
$(SYNTH_CHECKPOINT): check
	@echo "Starting synthesis phase..."
	@mkdir -p $(SYNTH_DIR)
	@mkdir -p $(REPORTS_DIR)
	@echo "Synthesizing design using Vivado..."
	@$(VIVADO) $(VIVADO_FLAGS) -source $(SCRIPT_DIR)/$(VIVADO_SCRIPT_SYNTH) \
		-log $(SYNTH_DIR)/vivado_synth.log \
		-journal $(SYNTH_DIR)/vivado_synth.jou
	@if [ -f $(SYNTH_CHECKPOINT) ]; then \
		echo "✓ Synthesis successful!"; \
	else \
		echo "✗ Synthesis failed - check logs"; exit 1; \
	fi

synth: $(SYNTH_CHECKPOINT)

# Implementation (Place & Route) target
$(IMPL_CHECKPOINT): $(SYNTH_CHECKPOINT)
	@echo "Starting implementation phase..."
	@mkdir -p $(IMPL_DIR)
	@echo "Running place and route..."
	@$(VIVADO) $(VIVADO_FLAGS) -source $(SCRIPT_DIR)/$(VIVADO_SCRIPT_IMPL) \
		-log $(IMPL_DIR)/vivado_impl.log \
		-journal $(IMPL_DIR)/vivado_impl.jou
	@if [ -f $(IMPL_CHECKPOINT) ]; then \
		echo "✓ Implementation successful!"; \
	else \
		echo "✗ Implementation failed - check logs"; exit 1; \
	fi

impl: $(IMPL_CHECKPOINT)

# Bitstream generation target
$(BITSTREAM): $(IMPL_CHECKPOINT)
	@echo "Generating bitstream..."
	@mkdir -p $(BIT_DIR)
	@$(VIVADO) $(VIVADO_FLAGS) -source $(SCRIPT_DIR)/vivado_bitstream.tcl \
		-log $(BIT_DIR)/vivado_bit.log \
		-journal $(BIT_DIR)/vivado_bit.jou
	@if [ -f $(BITSTREAM) ]; then \
		echo "✓ Bitstream generation successful!"; \
		echo "  File: $(BITSTREAM)"; \
		echo "  Size: $$(du -h $(BITSTREAM) | cut -f1)"; \
	else \
		echo "✗ Bitstream generation failed"; exit 1; \
	fi

bitstream: $(BITSTREAM)

#############################################################################
# Report Generation Targets
#############################################################################

report-timing: $(IMPL_CHECKPOINT)
	@echo "Generating timing report..."
	@mkdir -p $(REPORTS_DIR)
	@$(VIVADO) $(VIVADO_FLAGS) -source $(SCRIPT_DIR)/vivado_timing.tcl \
		-log $(REPORTS_DIR)/timing.log

report-util: $(IMPL_CHECKPOINT)
	@echo "Generating utilization report..."
	@mkdir -p $(REPORTS_DIR)
	@$(VIVADO) $(VIVADO_FLAGS) -source $(SCRIPT_DIR)/vivado_utilization.tcl \
		-log $(REPORTS_DIR)/utilization.log

reports: report-timing report-util
	@echo "✓ Reports generated in $(REPORTS_DIR)"

#############################################################################
# Status and Information Targets
#############################################################################

status:
	@echo ""
	@echo "Build Status:"
	@echo "=============================================================="
	@if [ -f $(SYNTH_CHECKPOINT) ]; then \
		echo "✓ Synthesis checkpoint: READY"; \
	else \
		echo "✗ Synthesis checkpoint: NOT FOUND"; \
	fi
	@if [ -f $(IMPL_CHECKPOINT) ]; then \
		echo "✓ Implementation checkpoint: READY"; \
	else \
		echo "✗ Implementation checkpoint: NOT FOUND"; \
	fi
	@if [ -f $(BITSTREAM) ]; then \
		echo "✓ Bitstream: READY"; \
		ls -lh $(BITSTREAM); \
	else \
		echo "✗ Bitstream: NOT FOUND"; \
	fi
	@echo ""

device-info:
	@echo "Device Information:"
	@echo "=============================================================="
	@echo "Device: $(PART)"
	@echo "Part: XC7A100T (Artix-7)"
	@echo "Package: CSG324"
	@echo "Speed Grade: -1"
	@echo "Logic Cells: ~101,440"
	@echo "Block RAM: 4,860 Kb"
	@echo "DSP48A Slices: 240"
	@echo "Board: Digilent Arty A7-100T"
	@echo ""

#############################################################################
# Programming Target
#############################################################################

program: $(BITSTREAM)
	@echo ""
	@echo "Programming FPGA..."
	@echo "=============================================================="
	@echo "Bitstream: $(BITSTREAM)"
	@echo "Serial Port: $(SERIAL_PORT)"
	@echo ""
	@if [ ! -c $(SERIAL_PORT) ]; then \
		echo "ERROR: Serial port $(SERIAL_PORT) not found"; \
		echo "Available ports:"; \
		ls -la /dev/ttyUSB* /dev/ttyACM* 2>/dev/null || echo "  (none found)"; \
		exit 1; \
	fi
	@echo "✓ Serial port found: $(SERIAL_PORT)"
	@echo "Programming device..."
	@$(VIVADO) $(VIVADO_FLAGS) -source $(SCRIPT_DIR)/$(VIVADO_SCRIPT_PROG) \
		-log $(BIT_DIR)/program.log

#############################################################################
# Cleanup Targets
#############################################################################

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -rf .Xil
	@echo "✓ Clean complete"

distclean: clean
	@echo "Removing all generated files..."
	@rm -rf $(BIT_DIR)
	@rm -rf *.backup *.log *.jou
	@echo "✓ Distclean complete"

#############################################################################
# Development Targets
#############################################################################

# Open design in Vivado GUI (for debugging)
open: $(IMPL_CHECKPOINT)
	@echo "Opening design in Vivado GUI..."
	@$(VIVADO) -open_project $(BUILD_DIR)/$(PROJECT_NAME).xpr &

# View synthesis logs
log-synth:
	@less $(SYNTH_DIR)/vivado_synth.log

# View implementation logs  
log-impl:
	@less $(IMPL_DIR)/vivado_impl.log

# View bitstream generation logs
log-bit:
	@less $(BIT_DIR)/vivado_bit.log

#############################################################################
# Documentation Targets
#############################################################################

info:
	@echo "Build Information:"
	@echo "=============================================================="
	@echo "Project: $(PROJECT_NAME)"
	@echo "Device: $(PART)"
	@echo "Board: $(BOARD)"
	@echo "RTL Directory: $(RTL_DIR)"
	@echo "Build Directory: $(BUILD_DIR)"
	@echo "Bitstream Output: $(BIT_DIR)"
	@echo "Constraint File: $(CONSTRAINT_FILE)"
	@echo ""
	@echo "Build Directories:"
	@echo "  $(SYNTH_DIR) - Synthesis outputs"
	@echo "  $(IMPL_DIR) - Implementation outputs"
	@echo "  $(BIT_DIR) - Bitstream and reports"
	@echo ""

#############################################################################
# Rules and Dependencies
#############################################################################

# Mark these as phony targets
.PHONY: all build synth impl bitstream clean distclean check help status
.PHONY: program open log-synth log-impl log-bit reports report-timing report-util
.PHONY: device-info info

# Precious files (don't auto-delete)
.PRECIOUS: $(SYNTH_CHECKPOINT) $(IMPL_CHECKPOINT)

#############################################################################
# Default configuration
#############################################################################

# Show info on first run
ifeq ($(MAKECMDGOALS),)
.PHONY: initial-help
initial-help:
	@$(MAKE) help
endif

# ============================================================================
# END OF MAKEFILE
# ============================================================================
