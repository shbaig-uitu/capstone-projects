# Set these for the PDK/library assigned by your course.
export PDK_ROOT ?= /path/to/your/pdk
export TECH_LEF ?= $(PDK_ROOT)/lef/technology.lef
export STD_CELL_LEF ?= $(PDK_ROOT)/lef/stdcells.lef
export STD_CELL_LIB ?= $(PDK_ROOT)/lib/stdcells.lib
export TOP ?= riscv_vga_soc
export NETLIST ?= ../../build_asic/riscv_vga_soc.v
export SDC ?= top.sdc
export REPORT_DIR ?= ../reports
