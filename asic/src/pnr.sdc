# ============================================================================
# RISC-V SoC ASIC P&R SDC Constraints
# ============================================================================
# Target: SKY130 130nm Process
# Purpose: Define placement, routing, and timing constraints for P&R stage
# This file is used by OpenROAD place and route tool
# ============================================================================

# ============================================================================
# 1. CLOCK NETWORK CONSTRAINTS
# ============================================================================

# Primary clock definition (inherited from implementation)
create_clock -name clk -period 10.0 [get_ports clk]

# Clock network setup for CTS
set_clock_uncertainty 0.5 [get_clocks clk]

# Clock is routed on upper metal (M5 for minimal RC)
set_routing_layer clk M5

# Maximum skew between clock tree endpoints (4% of period = 400ps)
set_max_skew 0.4 [get_clocks clk]

# Clock buffer constraints
set_clock_tree_buffer sky130_fd_sc_hd__buf_4
set_clock_tree_inverter sky130_fd_sc_hd__inv_4

# Root clock pin for CTS
set_clock_tree_root clk [get_ports clk]

# ============================================================================
# 2. PLACEMENT CONSTRAINTS
# ============================================================================

# Core placement region (excluding pad ring)
# Assume 3.5mm x 3.5mm core area with 50um pad offset
set_placement_region core_area \
  -left 50 -right 3550 \
  -bottom 50 -top 3550

# Constraint all instances to core placement region
set_placement_region core_area \
  -instances [get_cells riscv_soc_top/*]

# Placement density target (70-75% for this design)
set_placement_density 0.75

# Margin from core boundary (avoid placing logic too close to edges)
set_placement_boundary_margin 50  # um

# ============================================================================
# 3. MEMORY MACRO PLACEMENT
# ============================================================================

# Instruction SRAM macro - place in lower left quadrant for routing efficiency
set_placement_region inst_sram_region \
  -left 100 -right 1000 \
  -bottom 100 -top 1000

set_placement_fixed_instance \
  riscv_soc_top/inst_sram_inst \
  -x 500 -y 500

# Data SRAM macro - place in lower right quadrant
set_placement_region data_sram_region \
  -left 2500 -right 3450 \
  -bottom 100 -top 1000

set_placement_fixed_instance \
  riscv_soc_top/data_sram_inst \
  -x 3000 -y 500

# ============================================================================
# 4. POWER DISTRIBUTION CONSTRAINTS
# ============================================================================

# Power stripe parameters for PDN
set_power_stripe_width 10         # um
set_power_stripe_pitch 50         # um (center to center)
set_power_stripe_offset 20        # um from core edge

# Power stripes on M4 (horizontal) and M5 (vertical)
set_power_net_layer VDD M4 M5
set_power_net_layer VSS M4 M5

# Minimum width to prevent IR drop violations
set_power_net_min_width VDD 10    # um
set_power_net_min_width VSS 10    # um

# Maximum current per stripe (SKY130 manufacturing limit)
set_max_current_per_stripe 100    # mA/mm

# ============================================================================
# 5. ROUTING CONSTRAINTS
# ============================================================================

# Preferred routing layers for different net types
# Data buses on lower metal (M2/M3) for area efficiency
set_preferred_routing_layer data_vaddr M2
set_preferred_routing_layer data_wdata M2
set_preferred_routing_layer data_rdata M2
set_preferred_routing_layer inst_vaddr M2
set_preferred_routing_layer inst_data M2

# Address buses: use M3 (one layer up)
set_preferred_routing_layer axi_awaddr M3
set_preferred_routing_layer axi_araddr M3
set_preferred_routing_layer axi_wdata M3
set_preferred_routing_layer axi_rdata M3

# Power network uses M4/M5 (upper metals, lower resistance)
set_power_net_layer VDD M4 M5
set_power_net_layer VSS M4 M5

# Clock network uses M5 (minimize skew with upper layer)
set_clock_routing_layer clk M5

# Control signals can use M2-M4
set_preferred_routing_layer inst_valid M3
set_preferred_routing_layer data_valid M3
set_preferred_routing_layer data_write M3

# ============================================================================
# 6. CRITICAL PATH ROUTING PRIORITIES
# ============================================================================

# Instruction fetch path (PC -> Inst address)
set_net_priority inst_vaddr[*] -priority 1   # Highest priority
set_net_priority inst_valid -priority 1

# Instruction decode path
set_net_priority inst_data[*] -priority 1

# Data address path
set_net_priority data_vaddr[*] -priority 1

# ALU result paths are internal (no special routing needed)

# ============================================================================
# 7. TIMING-DRIVEN ROUTING
# ============================================================================

# Enable timing-driven routing for critical paths
set_timing_driven_routing true

# Slew rate targets for different path types
set_max_slew 0.5 [get_nets inst_vaddr[*]]     # Fast paths: 500ps
set_max_slew 0.5 [get_nets data_vaddr[*]]
set_max_slew 0.5 [get_nets clk]

set_max_slew 1.0 [get_nets gpio_*]             # Slow paths: 1ns
set_max_slew 1.0 [get_nets uart_*]

# Capacitance limits (prevent excessive loading)
set_max_capacitance 0.05 [get_nets inst_vaddr[*]]   # 50fF
set_max_capacitance 0.05 [get_nets data_vaddr[*]]

# ============================================================================
# 8. SIGNAL INTEGRITY CONSTRAINTS
# ============================================================================

# Shielding for high-speed buses (minimize crosstalk)
set_shield_net data_vaddr[*] VSS      # Shield address buses with ground
set_shield_net inst_vaddr[*] VSS
set_shield_net clk VSS                # Shield clock with VSS

# Guard ring spacing (keep away from sensitive analog circuits)
set_guard_ring_width 10               # um

# ============================================================================
# 9. CONGESTION MANAGEMENT
# ============================================================================

# Target congestion levels
set_congestion_threshold 0.9          # Stop routing if >90% congested
set_congestion_iterations 100         # Max iterations to unclog

# Reserve space in high-traffic areas
# Area around pad ring
set_routing_blockage -left 0 -right 100 -bottom 0 -top 3600
set_routing_blockage -left 0 -right 3600 -bottom 3500 -top 3600
set_routing_blockage -left 3500 -right 3600 -bottom 0 -top 3600
set_routing_blockage -left 0 -right 100 -bottom 0 -top 3600

# ============================================================================
# 10. VIA CONFIGURATION
# ============================================================================

# Via types and preferences
set_via_type VIA M1_M2_PRH           # Use preferred vias
set_via_type VIA M2_M3_PRH
set_via_type VIA M3_M4_PRH
set_via_type VIA M4_M5_PRH

# Via spacing rules (SKY130)
set_min_via_spacing 0.17 [get_lef sky130_fd_sc_hd.lef]

# Via current capacity (for power delivery)
set_max_current_via 1.0              # 1mA per via

# ============================================================================
# 11. FILLER CELL PLACEMENT
# ============================================================================

# Filler cells required by SKY130 manufacturing
set_use_filler_cells true
set_filler_cell_prefix FILLER

# Types of filler cells
set_filler_cells sky130_fd_sc_hd__fill_1
set_filler_cells sky130_fd_sc_hd__fill_2
set_filler_cells sky130_fd_sc_hd__fill_4
set_filler_cells sky130_fd_sc_hd__fill_8

# Metal fill for CMP (chemical mechanical polishing)
set_metal_fill_enable true
set_metal_fill_density 0.3           # 30% of available area

# ============================================================================
# 12. ANTENNA RULE CONSTRAINTS
# ============================================================================

# Antenna checking for ESD protection
set_antenna_check_enable true
set_max_antenna_ratio 200            # NMOS max gate to channel width
set_max_antenna_ratio 300 -layer M5  # Higher for top metal

# Antenna diodes for long routing
set_antenna_diode_cell sky130_fd_sc_hd__diode_2
set_insert_antenna_diodes_mode auto

# ============================================================================
# 13. LAYER-SPECIFIC RULES (SKY130)
# ============================================================================

# Metal 1 (local interconnect, very congested)
set_layer_min_width M1 0.17          # um
set_layer_min_spacing M1 0.17        # um
set_preferred_direction M1 horizontal

# Metal 2 (general routing)
set_layer_min_width M2 0.15
set_layer_min_spacing M2 0.15
set_preferred_direction M2 vertical

# Metal 3 (general routing)
set_layer_min_width M3 0.15
set_layer_min_spacing M3 0.15
set_preferred_direction M3 horizontal

# Metal 4 (power distribution)
set_layer_min_width M4 0.30
set_layer_min_spacing M4 0.30
set_preferred_direction M4 vertical

# Metal 5 (top metal, power and clock)
set_layer_min_width M5 0.30
set_layer_min_spacing M5 0.30
set_preferred_direction M5 horizontal

# ============================================================================
# 14. TIMING PATH OPTIMIZATION
# ============================================================================

# Setup and hold time margins
set_setup_slack_margin 0.3           # 3% of period as margin
set_hold_slack_margin 0.1            # 1% of period as margin

# Buffer insertion optimization
set_buffer_insertion_enable true
set_max_buffer_fanout 20             # Prevent excessive loading
set_buffer_cell sky130_fd_sc_hd__buf_2

# Sizing for timing optimization
set_cell_sizing_enable true
set_max_cell_size 4x                 # Limit cell size for leakage control

# ============================================================================
# 15. POWER ANALYSIS CONSTRAINTS
# ============================================================================

# Leakage current concerns at 1.8V
set_max_leakage_power 5.0            # 5mW target

# Dynamic power estimation
set_switching_activity_file null     # Use default static activity (10%)
set_default_switching_activity 0.1   # 10% default activity factor

# Power supply voltage noise
set_max_ir_drop 0.18                 # 10% max voltage droop (1.62V minimum)

# ============================================================================
# 16. CLOCK TREE SYNTHESIS DETAILS
# ============================================================================

# Clock tree budget
set_clock_tree_depth 5               # Max depth from root to leaf
set_clock_tree_fanout 20             # Buffer fanout limit

# CTS buffering strategy
set_cts_buffer_cell sky130_fd_sc_hd__buf_4
set_cts_inverter_cell sky130_fd_sc_hd__inv_4

# Insertion delay target
set_max_insertion_delay 1.5          # ns (15% of period)

# Skew target
set_max_clock_skew 0.4               # ns (4% of period)

# ============================================================================
# 17. DESIGN FOR TEST (DFT)
# ============================================================================

# Scan chain setup (if implemented)
set_scan_chain_length 512            # Estimated FF count

# Built-in self-test (BIST) constraints
set_memory_bist_enable true
set_mbist_controller_placement center  # Place at core center

# ============================================================================
# 18. POST-ROUTE OPTIMIZATION
# ============================================================================

# Eco (Engineering Change Order) mode disabled
set_eco_mode false

# Incremental timing optimization
set_timing_update_enable true

# Slack distribution
set_slack_target 0.3                 # Target 3% margin for all paths

# ============================================================================
# 19. DETAILED ROUTING PARAMETERS
# ============================================================================

# Router configuration
set_routing_algorithm parallel_processing
set_routing_iterations 3

# Overflow iterations
set_overflow_iterations 100
set_max_search_depth 1000

# Track assignment
set_track_assign_iterations 5

# ============================================================================
# 20. SIGNOFF PREPARATION
# ============================================================================

# GDSII output configuration
set_gds_layer_map sky130A
set_gds_output_version 6.0

# Net naming convention
set_net_name_separator "/"

# Instance hierarchy
set_hierarchy_separator "/"

# Physical hierarchy
set_keep_hierarchy true

# ============================================================================
# SUMMARY OF P&R CONSTRAINTS
# ============================================================================
# Clock: 10ns period, 0.4ns max skew, M5 routing
# Core placement: 3.5mm x 3.5mm, 70-75% density
# Memory macros: Pre-placed for routing efficiency
# Power: M4/M5 stripes, 10um width, 50um pitch
# Critical paths: Priority 1 routing, M2/M3 layers
# Congestion: Target 90% threshold, 100 iterations
# Signal integrity: Guard bands, shielding on busses
# Manufacturing: Antenna checks, filler cells, metal fill
# ============================================================================
