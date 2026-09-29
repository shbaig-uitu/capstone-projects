## Project 02 timing constraints for Arty A7-100T.
## The 100 MHz board clock is constrained in the board XDC. Generated clocks
## from the MMCM are constrained automatically by Vivado's clock propagation.
set_false_path -from [get_ports btn_reset]
