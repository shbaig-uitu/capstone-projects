###############################################################################
# Created by write_sdc
###############################################################################
current_design soc_top
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 20.0000 [get_ports {clk}]
set_clock_uncertainty 0.2000 clk
set_propagated_clock [get_clocks {clk}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {led[0]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {led[1]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {led[2]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {led[3]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {led[4]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {led[5]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {led[6]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {led[7]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {mbox_c0_to_c1_flag}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {mbox_c1_to_c0_flag}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uart_tx}]
set_false_path\
    -from [get_ports {rst_n}]
###############################################################################
# Environment
###############################################################################
###############################################################################
# Design Rules
###############################################################################
