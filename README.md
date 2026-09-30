# Dual-Core SoC ASIC Folder

This folder is ready to use as a LibreLane design directory.

- `src` contains the synthesizable RTL and timing constraints.
- `verify` contains one small self-checking RTL testbench.
- `config.yaml` contains the initial Sky130 ASIC settings.
- `pin_order.cfg` contains the four top-level pin groups.
- The two firmware files stay beside `config.yaml` because the instruction memories load them by name.

The shared data memory is 64 words (256 bytes) and each instruction memory is 32 words (128 bytes). This is enough for the supplied programs and substantially reduces the flip-flop memory, decoder, routing load, and run time. Shared-memory requests are registered and the interconnect keeps the same core selected until the memory response returns.

The previous run completed GDS with zero DRC, LVS, antenna, XOR, and hold violations. Its main problem was a worst setup slack of about -3.47 ns at the slow corner, together with slew and fanout violations. The new configuration keeps the 20 ns clock for the first optimized run, enables the supplied SDC files, uses delay-oriented synthesis, raises the maximum fanout from 10 to 32, uses a lighter PDN pitch, and reduces the initial die to 1000 by 1000 micrometres.

Run RTL verification from this directory with:

```powershell
iverilog -g2012 -s tb_dual_core_soc -o dual_core_soc.vvp verify/tb_dual_core_soc.v src/*.v
vvp dual_core_soc.vvp
```

Run LibreLane from this directory with `config.yaml`. Keep the first new run results so timing, utilization, congestion, and area can be adjusted from measured data.
