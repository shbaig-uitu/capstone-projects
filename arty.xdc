## Arty A7-100T
## 100 MHz system clock
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk -period 10.000 [get_ports clk]

## Red RESET button: active-low
set_property PACKAGE_PIN C2 [get_ports reset_n]
set_property IOSTANDARD LVCMOS33 [get_ports reset_n]

## User LEDs: LD4, LD5, LD6, LD7
set_property PACKAGE_PIN H5 [get_ports led_fault]
set_property IOSTANDARD LVCMOS33 [get_ports led_fault]

set_property PACKAGE_PIN J5 [get_ports led_hit]
set_property IOSTANDARD LVCMOS33 [get_ports led_hit]

set_property PACKAGE_PIN T9 [get_ports led_miss]
set_property IOSTANDARD LVCMOS33 [get_ports led_miss]

set_property PACKAGE_PIN T10 [get_ports led_boot]
set_property IOSTANDARD LVCMOS33 [get_ports led_boot]

## USB-UART: FPGA TX -> host RX
## Arty A7 FPGA-side TX is D10.
set_property PACKAGE_PIN D10 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]
