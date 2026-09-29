# ASIC synthesis and physical design

## Yosys synthesis

From the project root:

```bash
make asic
```

This synthesizes `riscv_vga_soc` and writes:

```text
build_asic/riscv_vga_soc.v
```

The submitted package includes the generated netlist from the completed synthesis run.

## OpenROAD

OpenROAD constraints and starter scripts are under `physical_design/openroad/`. The initial clock constraints are 20 ns for the 50 MHz system clock and 40 ns for the 25 MHz VGA clock.

A full top-level routed GDS was not completed. The main implementation issue is the large inferred memory system (32 KiB IMEM, 32 KiB DMEM and 307,200-byte framebuffer). A practical Sky130 implementation requires explicit SRAM-macro integration rather than mapping the framebuffer to standard-cell storage.

The package therefore includes the synthesis result and PD setup/scripts, but does not claim final area, power, congestion, DRC, LVS or GDS sign-off values.
