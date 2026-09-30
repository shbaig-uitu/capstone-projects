# 50 MHz primary clock
create_clock -name clk -period 20.000 [get_ports clk]

# Small initial margin; refine after synthesis/STA reports.
set_clock_uncertainty 0.200 [get_clocks clk]

# rst_n is an asynchronous active-low reset in this RTL.
set_false_path -from [get_ports rst_n]

# Top-level outputs go off-chip / to FPGA-style status interfaces.
# These are starter constraints and can be changed if your instructor gives I/O timing.
set_output_delay 2.000 -clock [get_clocks clk] [get_ports {uart_tx led[*] mbox_c0_to_c1_flag mbox_c1_to_c0_flag}]
