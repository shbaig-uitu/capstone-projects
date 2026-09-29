# Vivado batch build: Digilent Arty A7-100T, XC7A100TCSG324-1.
set project_name "riscv_vga_soc"
set project_dir "./vivado_project"
set top_module "arty_a7_100t_vga_top"
set fpga_part "xc7a100tcsg324-1"

create_project $project_name $project_dir -part $fpga_part -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

set firmware_hex [file normalize "../firmware/firmware.hex"]
if {![file exists $firmware_hex]} { error "Missing $firmware_hex. Run make firmware." }
add_files -norecurse $firmware_hex
set_property generic [format {IMEM_INIT_FILE="%s"} $firmware_hex] [current_fileset]
add_files -norecurse [glob ../rtl/core/*.v]
add_files -norecurse [glob ../rtl/interconnect/*.v]
add_files -norecurse [glob ../rtl/peripherals/*.v]
add_files -norecurse ../rtl/top/riscv_vga_soc.v
add_files -norecurse ../rtl/top/arty_a7_100t_vga_top.v
add_files -fileset constrs_1 -norecurse ../constraints/pins/arty_a7_100t_pmod_vga.xdc
add_files -fileset constrs_1 -norecurse ../constraints/timing/arty_a7_100t_timing.xdc
set_property top $top_module [current_fileset]
update_compile_order -fileset sources_1

launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[string match *ERROR* [get_property STATUS [get_runs synth_1]]]} { error "Synthesis failed" }
open_run synth_1
report_utilization -file $project_dir/utilization_synth.rpt
report_timing_summary -file $project_dir/timing_synth.rpt

launch_runs impl_1 -jobs 4
wait_on_run impl_1
open_run impl_1
report_utilization -file $project_dir/utilization_impl.rpt
report_timing_summary -file $project_dir/timing_impl.rpt
report_power -file $project_dir/power.rpt
report_drc -file $project_dir/drc.rpt
report_methodology -file $project_dir/methodology.rpt

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
file mkdir ../build
set bitfile $project_dir/$project_name.runs/impl_1/$top_module.bit
if {![file exists $bitfile]} { error "Bitstream not generated: $bitfile" }
file copy -force $bitfile ../build/$project_name.bit
puts "BITSTREAM: ../build/$project_name.bit"
