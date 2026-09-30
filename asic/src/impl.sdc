# ============================================================================
# RISC-V SoC ASIC Implementation SDC Constraints
# ============================================================================
# Target: SKY130 130nm Process
# Frequency: 100 MHz (10 ns clock period)
# Voltage: 1.8V (±10% tolerance)
# Temperature: 25°C (nominal TT corner)
#
# Purpose: Define timing constraints for synthesis and implementation
# ============================================================================

# ============================================================================
# 1. CLOCK DEFINITIONS
# ============================================================================

# Primary system clock
create_clock -name clk -period 10.0 [get_ports clk]

# Clock specifications
set_clock_uncertainty 0.5 [get_clocks clk]        # 5% of period (50 ps)
set_clock_latency 0.2 [get_clocks clk]            # Clock distribution latency (200 ps)

# ============================================================================
# 2. RESET SIGNAL
# ============================================================================

# Reset is asynchronous - no timing constraints
# But ensure all synchronous reset paths are respected
set_false_path -from [get_ports rst_n] -to [get_clocks clk]

# ============================================================================
# 3. INPUT/OUTPUT CONSTRAINTS
# ============================================================================

# Instruction Memory Interface Inputs
set_input_delay -clock clk -max 2.0 [get_ports inst_data[*]]
set_input_delay -clock clk -max 2.0 [get_ports inst_ready]
set_input_delay -clock clk -max 2.0 [get_ports inst_page_fault]
set_input_delay -clock clk -min 0.5 [get_ports inst_data[*]]
set_input_delay -clock clk -min 0.5 [get_ports inst_ready]
set_input_delay -clock clk -min 0.5 [get_ports inst_page_fault]

# Instruction Memory Interface Outputs
set_output_delay -clock clk -max 1.5 [get_ports inst_vaddr[*]]
set_output_delay -clock clk -max 1.5 [get_ports inst_valid]
set_output_delay -clock clk -min 0.1 [get_ports inst_vaddr[*]]
set_output_delay -clock clk -min 0.1 [get_ports inst_valid]

# Data Memory Interface Inputs
set_input_delay -clock clk -max 2.0 [get_ports data_rdata[*]]
set_input_delay -clock clk -max 2.0 [get_ports data_ready]
set_input_delay -clock clk -max 2.0 [get_ports data_page_fault]
set_input_delay -clock clk -min 0.5 [get_ports data_rdata[*]]
set_input_delay -clock clk -min 0.5 [get_ports data_ready]
set_input_delay -clock clk -min 0.5 [get_ports data_page_fault]

# Data Memory Interface Outputs
set_output_delay -clock clk -max 1.5 [get_ports data_vaddr[*]]
set_output_delay -clock clk -max 1.5 [get_ports data_valid]
set_output_delay -clock clk -max 1.5 [get_ports data_write]
set_output_delay -clock clk -max 1.5 [get_ports data_wdata[*]]
set_output_delay -clock clk -max 1.5 [get_ports data_byte_en[*]]
set_output_delay -clock clk -min 0.1 [get_ports data_vaddr[*]]
set_output_delay -clock clk -min 0.1 [get_ports data_valid]
set_output_delay -clock clk -min 0.1 [get_ports data_write]
set_output_delay -clock clk -min 0.1 [get_ports data_wdata[*]]
set_output_delay -clock clk -min 0.1 [get_ports data_byte_en[*]]

# ============================================================================
# 4. AXI4-LITE DEBUG INTERFACE CONSTRAINTS
# ============================================================================

# Write Address Channel
set_input_delay -clock clk -max 2.5 [get_ports axi_awaddr[*]]
set_input_delay -clock clk -max 2.5 [get_ports axi_awvalid]
set_input_delay -clock clk -min 0.5 [get_ports axi_awaddr[*]]
set_input_delay -clock clk -min 0.5 [get_ports axi_awvalid]

set_output_delay -clock clk -max 2.0 [get_ports axi_awready]
set_output_delay -clock clk -min 0.2 [get_ports axi_awready]

# Write Data Channel
set_input_delay -clock clk -max 2.5 [get_ports axi_wdata[*]]
set_input_delay -clock clk -max 2.5 [get_ports axi_wstrb[*]]
set_input_delay -clock clk -max 2.5 [get_ports axi_wvalid]
set_input_delay -clock clk -min 0.5 [get_ports axi_wdata[*]]
set_input_delay -clock clk -min 0.5 [get_ports axi_wstrb[*]]
set_input_delay -clock clk -min 0.5 [get_ports axi_wvalid]

set_output_delay -clock clk -max 2.0 [get_ports axi_wready]
set_output_delay -clock clk -min 0.2 [get_ports axi_wready]

# Write Response Channel
set_output_delay -clock clk -max 2.0 [get_ports axi_bresp[*]]
set_output_delay -clock clk -max 2.0 [get_ports axi_bvalid]
set_output_delay -clock clk -min 0.2 [get_ports axi_bresp[*]]
set_output_delay -clock clk -min 0.2 [get_ports axi_bvalid]

set_input_delay -clock clk -max 2.5 [get_ports axi_bready]
set_input_delay -clock clk -min 0.5 [get_ports axi_bready]

# Read Address Channel
set_input_delay -clock clk -max 2.5 [get_ports axi_araddr[*]]
set_input_delay -clock clk -max 2.5 [get_ports axi_arvalid]
set_input_delay -clock clk -min 0.5 [get_ports axi_araddr[*]]
set_input_delay -clock clk -min 0.5 [get_ports axi_arvalid]

set_output_delay -clock clk -max 2.0 [get_ports axi_arready]
set_output_delay -clock clk -min 0.2 [get_ports axi_arready]

# Read Data Channel
set_output_delay -clock clk -max 2.0 [get_ports axi_rdata[*]]
set_output_delay -clock clk -max 2.0 [get_ports axi_rresp[*]]
set_output_delay -clock clk -max 2.0 [get_ports axi_rvalid]
set_output_delay -clock clk -min 0.2 [get_ports axi_rdata[*]]
set_output_delay -clock clk -min 0.2 [get_ports axi_rresp[*]]
set_output_delay -clock clk -min 0.2 [get_ports axi_rvalid]

set_input_delay -clock clk -max 2.5 [get_ports axi_rready]
set_input_delay -clock clk -min 0.5 [get_ports axi_rready]

# ============================================================================
# 5. PERIPHERAL INTERFACE CONSTRAINTS
# ============================================================================

# UART Interface (slower timing - asynchronous domain)
set_input_delay -clock clk -max 5.0 [get_ports uart_rx]
set_input_delay -clock clk -min 2.0 [get_ports uart_rx]

set_output_delay -clock clk -max 5.0 [get_ports uart_tx]
set_output_delay -clock clk -min 2.0 [get_ports uart_tx]

# GPIO Interface (slow I/O)
set_input_delay -clock clk -max 5.0 [get_ports gpio_in[*]]
set_input_delay -clock clk -min 2.0 [get_ports gpio_in[*]]

set_output_delay -clock clk -max 5.0 [get_ports gpio_out[*]]
set_output_delay -clock clk -min 2.0 [get_ports gpio_out[*]]

# External Interrupt (asynchronous)
set_false_path -from [get_ports ext_interrupt] -to [get_clocks clk]

# ============================================================================
# 6. TIMING PATH EXCEPTIONS
# ============================================================================

# Asynchronous inputs that are synchronized internally
# No timing requirement between ext_interrupt and clk (async)
# Synchronizers will handle the timing relationship

# ============================================================================
# 7. CLOCK TO OUTPUT (C2Q) CONSTRAINTS
# ============================================================================

# Register to output paths should be within budget
# For a 10ns clock at 100MHz, C2Q + routing should be ~3-4ns
set_max_delay 3.0 -from [get_clocks clk] -to [get_ports inst_vaddr[*]]
set_max_delay 3.0 -from [get_clocks clk] -to [get_ports inst_valid]
set_max_delay 3.0 -from [get_clocks clk] -to [get_ports data_vaddr[*]]
set_max_delay 3.0 -from [get_clocks clk] -to [get_ports data_valid]
set_max_delay 3.0 -from [get_clocks clk] -to [get_ports data_write]
set_max_delay 3.0 -from [get_clocks clk] -to [get_ports data_wdata[*]]
set_max_delay 3.0 -from [get_clocks clk] -to [get_ports data_byte_en[*]]

# ============================================================================
# 8. INTERNAL TIMING CONSTRAINTS
# ============================================================================

# Critical paths in the design
# ALU combinational logic should complete within 2-3ns (20-30% of clock period)
set_max_delay 3.0 -from [get_pins rv32i_core/regfile*] -to [get_pins rv32i_core/alu*]

# Instruction decode path
set_max_delay 2.5 -from [get_pins rv32i_core/inst*] -to [get_pins rv32i_core/decoder*]

# TLB lookup combinational path (critical for single-cycle hit)
set_max_delay 2.0 -from [get_pins mmu_inst/tlb*] -to [get_pins mmu_inst/out*]

# MMU translation path
set_max_delay 3.5 -from [get_pins mmu_inst/in*] -to [get_pins mmu_inst/out*]

# ============================================================================
# 9. POWER SUPPLY CONSTRAINTS
# ============================================================================

# Define power supply pins
set_case_analysis 1 [get_ports clk]            # Clock is active high
set_case_analysis 0 [get_ports rst_n]          # Reset is active low (during synthesis)

# ============================================================================
# 10. MULTI-CYCLE PATHS
# ============================================================================

# Memory interface typically has multi-cycle latency
# Instruction read: typically 2-3 cycles
set_multicycle_path 3 -from [get_clocks clk] -to [get_ports inst_data[*]]

# Data read: typically 2-3 cycles
set_multicycle_path 3 -from [get_clocks clk] -to [get_ports data_rdata[*]]

# ============================================================================
# 11. FALSE PATHS
# ============================================================================

# Paths that should not be timed (cross-domain, etc.)
# External async signals
set_false_path -from [get_ports ext_interrupt]

# GPIO is not synchronous with core clock
set_false_path -from [get_ports gpio_in[*]]
set_false_path -to [get_ports gpio_out[*]]

# UART is async
set_false_path -from [get_ports uart_rx]
set_false_path -to [get_ports uart_tx]

# ============================================================================
# 12. HOLD TIME CONSTRAINTS
# ============================================================================

# Ensure minimum delay paths are also met
# Typically less critical, but important for setup/hold margins

# Setup time margin: 10% of clock period (1.0 ns for 10ns period)
set_clock_uncertainty -setup 0.5 [get_clocks clk]

# Hold time margin: 5% of clock period (0.5 ns)
set_clock_uncertainty -hold 0.2 [get_clocks clk]

# ============================================================================
# 13. DESIGN FOR MANUFACTURABILITY (DFM)
# ============================================================================

# Slew rate constraints (transition time)
set_max_transition 0.5 [get_clocks clk]        # Max 500 ps transition

# Fanout constraints
set_max_fanout 200 [get_all_inputs]            # Max 200 gate fanout

# ============================================================================
# 14. POWER DOMAIN CONSTRAINTS
# ============================================================================

# Single power domain (VDD = 1.8V, VSS = 0V)
# No power domain crossings
set_power_domain primary_power -elements {*}

# ============================================================================
# 15. LAYER ASSIGNMENT FOR CRITICAL PATHS
# ============================================================================

# Hint to router: use higher metal layers for these nets (lower R/C)
# ALU result bus
# Instruction decode bus
# Address buses (these are timing-critical)

# ============================================================================
# SUMMARY OF CONSTRAINTS
# ============================================================================
# Clock Period: 10.0 ns (100 MHz)
# Input Setup: 2.0 ns (20% margin)
# Output Delay: 1.5 ns (15% margin)
# Internal Path: 3.0-3.5 ns (30-35% margin)
# Max Fanout: 200 gates
# Max Slew: 0.5 ns (5% of period)
# Temperature: 25°C (TT corner)
# Voltage: 1.8V ±10%
# ============================================================================
