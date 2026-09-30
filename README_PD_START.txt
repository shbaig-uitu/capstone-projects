RISC-V SoC PD STARTER PACKAGE
============================

TOP MODULE
----------
soc_top

RTL INCLUDED
------------
addr_decoder.v
alu.v
arbiter.v
decoder.v
gpio_peripheral.v
ic_mailbox.v
imem.v
noc_interconnect.v
regfile.v
rv321i_core.v
rv32i_soc_defines.v
shared_dmem.v
soc_top.v
uart_peripheral.v

NOT INCLUDED IN PD INPUT
------------------------
tb_soc_top.v
tb_noc_interconnect.sv
*.bak
*.vcd
*.wlf
*.mpf
*.mti

IMPORTANT FIX APPLIED TO THIS COPY
----------------------------------
Original soc_top.v instantiated:
    mailbox u_mailbox (...)
But ic_mailbox.v declares:
    module ic_mailbox (...)
This starter copy changes the instantiation to:
    ic_mailbox u_mailbox (...)

MEMORY WARNING
--------------
imem.v and shared_dmem.v use behavioral reg arrays. This is okay for RTL simulation,
but in ASIC synthesis they may become a very large amount of standard-cell logic or may
need SRAM/ROM macro handling. Do NOT assume the first GDS run will be practical until
we inspect the synthesis memory/cell report.

The firmware .hex files are kept in firmware/ for reference. soc_top currently has empty
INIT_FILE defaults, so synthesis is not yet explicitly loading these programs.

FIRST COMMANDS
--------------
From this folder, with your normal LibreLane Docker setup:

1) First run only synthesis and inspect whether hierarchy/memory is preserved:
   librelane --dockerized --to Yosys.Synthesis config.yaml

If your installed step name differs, run your usual LibreLane flow command and stop at
synthesis using the step names shown by your installation.

2) After synthesis passes, inspect:
   - cell count / area
   - warnings
   - inferred memories
   - whether core0/core1/interconnect still exist in the netlist
   - setup timing

Do not jump directly to full GDS until synthesis is clean.
