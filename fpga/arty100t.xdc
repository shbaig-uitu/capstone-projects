##############################################################################
# RISC-V SoC with Virtual Memory Support - Capstone Project
#
# File: arty100t.xdc
# Device: Xilinx Artix-7 A7-100T (XC7A100TCSG324-1)
# Board: Digilent Arty A7-100T
#
# Description: Vivado Design Constraints for Arty A7-100T FPGA
#              Defines I/O pin assignments, timing, and placement constraints
#              for the complete RISC-V SoC design with virtual memory support
##############################################################################

##############################################################################
# Device Configuration
##############################################################################

# Set device part
set_property PART xc7a100tcsg324-1 [current_design]

# Bitstream configuration
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CCLK_TRISTATE TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

##############################################################################
# Clock and Reset Signals
##############################################################################

# System Clock Input - 100 MHz (Pin E3 - CLK100MHZ on Arty)
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -add -name sys_clk -period 10.0 -waveform {0 5} [get_ports clk]

# Reset Signal - Active Low (Pin D9 - RESET button on Arty)
set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports rst_n]

##############################################################################
# UART Interface - Serial Communication
##############################################################################

# UART RX (from USB-UART device to FPGA) - Pin A9
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports uart_rx]

# UART TX (from FPGA to USB-UART device) - Pin D10
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports uart_tx]

# UART timing constraints (no tight timing required)
set_false_path -from [get_ports uart_rx]
set_false_path -to [get_ports uart_tx]

##############################################################################
# GPIO Interface - Outputs (LEDs)
##############################################################################

# GPIO Output bits [7:0] mapped to various resources
# gpio_out[0] - LD0 (Red LED) - Pin H17
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {gpio_out[0]}]

# gpio_out[1] - LD1 (Green LED) - Pin K15
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {gpio_out[1]}]

# gpio_out[2] - LD2 (Blue LED) - Pin J13
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {gpio_out[2]}]

# gpio_out[3] - LD3 (Green LED) - Pin N14
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {gpio_out[3]}]

# gpio_out[4:7] - Additional GPIO outputs (unused but defined)
# These can be connected to Pmod connectors or other resources as needed
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports {gpio_out[4]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports {gpio_out[5]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports {gpio_out[6]}]
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports {gpio_out[7]}]

##############################################################################
# GPIO Interface - Inputs (Switches)
##############################################################################

# GPIO Input bits [7:0] mapped to board resources
# gpio_in[0] - SW0 (Slide Switch 0) - Pin C9
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {gpio_in[0]}]

# gpio_in[1] - SW1 (Slide Switch 1) - Pin B9
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {gpio_in[1]}]

# gpio_in[2] - SW2 (Slide Switch 2) - Pin B8
set_property -dict {PACKAGE_PIN B8 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {gpio_in[2]}]

# gpio_in[3] - SW3 (Slide Switch 3) - Pin A8
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {gpio_in[3]}]

# gpio_in[4:7] - Additional GPIO inputs (unused but defined)
# These can be connected to Pmod connectors or other resources
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {gpio_in[4]}]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {gpio_in[5]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {gpio_in[6]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {gpio_in[7]}]

##############################################################################
# AXI4-Lite Debug Interface - Not routed in initial version
##############################################################################

# Note: AXI4-Lite debug interface signals are not routed to board pins
# in the current implementation. They are only available internally
# for future debug port implementation (JTAG, Xilinx Virtual Cable, etc.)
#
# Future expansion can route these to Pmod connectors:
# - PMOD JA: Can accommodate AXI4-Lite address/data channels
# - PMOD JB: Can accommodate AXI4-Lite response channels

##############################################################################
# External Interrupt
##############################################################################

# External Interrupt input (Button BTN0) - Pin D9 (shared with reset)
# Note: Currently mapped to reset. Can be remapped to separate button if needed
# Alternative: Use BTN1 (Pin C9), BTN2 (Pin B9), BTN3 (Pin B8)
# For now, external interrupt tied to reset signal for simplicity

##############################################################################
# Timing Constraints
##############################################################################

# System clock constraint (already defined above)
# Additional timing paths for async signals

# UART RX/TX - asynchronous, no strict timing
set_false_path -from [get_ports uart_rx]
set_false_path -to [get_ports uart_tx]

# GPIO inputs - asynchronous to system clock
set_false_path -from [get_ports {gpio_in[*]}] -to [get_clocks sys_clk]

# GPIO outputs - relaxed timing
set_false_path -from [get_clocks sys_clk] -to [get_ports {gpio_out[*]}]

# AXI signals (if used in future)
set_false_path -from [get_ports {axi_*}]
set_false_path -to [get_ports {axi_*}]

##############################################################################
# I/O Bank Configuration
##############################################################################

# Bank 34: 3.3V I/O (contains GPIO switches and other logic I/O)
# Bank 35: 3.3V I/O (contains GPIO outputs and UART)

# All used banks are configured for LVCMOS33 (3.3V)
# This is standard for Arty A7 board

##############################################################################
# Placement and Routing Constraints
##############################################################################

# Allow combinatorial loops for logic verification
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [current_design]

# No special placement constraints needed for basic implementation
# If performance optimization needed, add placement constraints here

##############################################################################
# Power and Temperature Configuration
##############################################################################

# No special power requirements - standard 3.3V operation

##############################################################################
# Configuration Notes
##############################################################################

# Device: XC7A100TCSG324-1
# Package: CSG324 (Ceramic Ball Grid Array)
# Speed Grade: -1 (commercial)
#
# Pins used:
# - E3: System Clock (100 MHz)
# - D9: Reset / Button 0
# - A9: UART RX
# - D10: UART TX
# - H17, K15, J13, N14: GPIO Output (LEDs 0-3)
# - C9, B9, B8, A8: GPIO Input (Switches 0-3)
#
# Available Pmod Connectors for future expansion:
# - PMOD JA (8 pins)
# - PMOD JB (8 pins)
# - PMOD JC (8 pins)
# - PMOD JD (8 pins)

# ============================================================================
# END OF CONSTRAINTS FILE
# ============================================================================
