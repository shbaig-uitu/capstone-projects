# PDK-neutral OpenROAD script for Project 02.
# Run only after setting TECH_LEF, STD_CELL_LEF, STD_CELL_LIB and NETLIST.

set top $::env(TOP)
set netlist $::env(NETLIST)
set tech_lef $::env(TECH_LEF)
set cell_lef $::env(STD_CELL_LEF)
set cell_lib $::env(STD_CELL_LIB)
set sdc $::env(SDC)
set report_dir $::env(REPORT_DIR)

file mkdir $report_dir

read_lef $tech_lef
read_lef $cell_lef
read_liberty $cell_lib
read_verilog $netlist
link_design $top
read_sdc $sdc

# Starter floorplan. Replace die/core dimensions with the dimensions required by
# the assigned technology and utilization target.
initialize_floorplan -die_area "0 0 1000 1000" -core_area "20 20 980 980" -site "core"
make_tracks

# Power planning is technology-specific. Keep the commands in one place so they
# can be edited for the course PDK instead of pretending a universal metal stack.
# Example structure:
#   define_pdn_grid -name main_grid -voltage_domains {CORE}
#   add_pdn_stripe -grid main_grid -layer M4 -width 2.0 -pitch 40.0
#   add_pdn_stripe -grid main_grid -layer M5 -width 2.0 -pitch 40.0 -offset 20.0
#   pdngen

report_design_area > [file join $report_dir area.rpt]
report_checks -path_delay max -fields {slew cap input_pin} -format full_clock_expanded > [file join $report_dir timing_preplace.rpt]

# Placement / optimization.
set_wire_rc -clock -layer M4
set_wire_rc -signal -layer M4
repair_design
place_design
resizer_timing -setup
repair_design

report_checks -path_delay max -format full_clock_expanded > [file join $report_dir timing_place.rpt]
report_design_area > [file join $report_dir area_place.rpt]

# CTS. The exact buffer cells may need to be supplied for the course library.
# clock_tree_synthesis -root_buf CLKBUF_X2 -buf_list {CLKBUF_X2 CLKBUF_X4}
# repair_clock_inverters
# clock_tree_synthesis -root_buf CLKBUF_X2 -buf_list {CLKBUF_X2 CLKBUF_X4}

# Routing. Uncomment after adapting layer names to the PDK.
# global_route
# repair_design
# detailed_route

# Save an intermediate database even when routing commands are still being
# adapted to the supplied PDK.
write_db [file join $report_dir project02_floorplan.odb]
report_checks -path_delay max -format full_clock_expanded > [file join $report_dir timing_final.rpt]
report_design_area > [file join $report_dir area_final.rpt]

puts "OpenROAD stage completed. Review the reports in $report_dir."
