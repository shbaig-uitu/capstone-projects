# Generic ASIC timing constraints. Adjust the input clock period to the course target.
# The RTL uses a 50 MHz system clock, so 20 ns is the initial constraint.
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]
set_input_delay  1.000 -clock clk_50mhz [all_inputs]
set_output_delay 1.000 -clock clk_50mhz [all_outputs]
set_false_path -from [get_ports rst_n]

# The VGA pixel clock is a separate clock domain.
create_clock -name clk_25mhz -period 40.000 [get_ports clk_25mhz]
set_clock_groups -asynchronous -group [get_clocks clk_50mhz] -group [get_clocks clk_25mhz]
