# Project 02 — Final Report

## 1. Introduction

This project implements a small RISC-V System-on-Chip capable of producing VGA graphics. A custom RV32I multicycle processor executes a bare-metal program and writes graphical information into a memory-mapped framebuffer. The VGA subsystem continuously reads the framebuffer and produces HSYNC, VSYNC and RGB332 output.

## 2. Architecture

The processor, instruction SRAM, data SRAM, framebuffer and VGA register block are connected by a compact memory interconnect. VGA configuration is exposed through an AXI4-Lite-style register interface. The framebuffer uses two independent clock ports: the CPU side uses 50 MHz and the VGA side uses 25 MHz.

The main memory regions are 32 KiB instruction memory, 32 KiB data memory and a 307,200-byte 640x480 framebuffer. The logical pixel address is `y*640+x`.

## 3. RV32I Processor

The CPU is a synthesizable multicycle RV32I core with a small control FSM and a native memory handshake. It implements the integer instruction subset needed by the bare-metal display firmware and keeps x0 hard-wired to zero. Loads and stores wait for `mem_ready` before completion.

## 4. VGA Subsystem

The VGA mode is 640x480 with an 800-clock horizontal raster and a 525-line frame. HSYNC and VSYNC are active low. RGB output is blanked outside the active video region and when display enable is cleared.

The framebuffer is synchronous-read RAM. The VGA controller uses next-pixel prefetch so the registered RAM data aligns with the pixel that becomes active after the clock edge.

## 5. Software

At reset, the firmware fills the framebuffer with RGB332 background color `0x9F`. It then writes `0x3` to the CTRL register, enabling both display output and the hardware duck animation.

## 6. Verification

The repository contains directed self-checking tests for the CPU, AXI4-Lite registers, memory interconnect, animation controller, VGA controller and complete SoC. The tests cover reset, normal accesses, framebuffer boundary accesses, invalid register/configuration accesses, sync timing, pixel-address behavior and display disable.

A separate UVM environment contains AXI and native-memory agents, sequences, monitors, scoreboards, functional coverage and SVA assertions. The UVM regression was executed in Questa Starter and completed with zero UVM errors and zero UVM fatals. Functional covergroups were disabled by the available `-nocvg` configuration, so a functional-coverage percentage is not reported.

## 7. FPGA Implementation

The FPGA wrapper targets the **Digilent Arty A7-100T**, device `XC7A100TCSG324-1`. The wrapper converts the board's 100 MHz oscillator to 50 MHz and 25 MHz using a 7-series MMCM and exposes RGB/HSYNC/VSYNC for the Digilent Pmod VGA interface.

A physical FPGA is not required for Vivado synthesis/implementation. A physical demonstration does require the Arty A7-100T, Pmod VGA and VGA monitor.

## 8. Physical Design

Yosys synthesis was completed for the full top-level design and the generated netlist is included under `build_asic/`. OpenROAD and Sky130 standard-cell/SRAM views were also evaluated. A complete top-level placement, CTS, routing, DRC/LVS and final GDS was not completed because the current design contains large inferred memories, including the 307,200-byte framebuffer, and requires explicit SRAM-macro integration for a realistic physical implementation.

## 9. Results

### Directed simulation

All six directed self-checking regressions pass. The logs are included under `sim/logs/`.

### UVM

The Questa UVM run completed with:

- `UVM_ERROR : 0`
- `UVM_FATAL : 0`
- simulator completion with no test failure

Functional covergroups were disabled in the available Starter configuration, so no functional-coverage percentage is claimed.

### FPGA implementation

The FPGA wrapper, XDC constraints and Vivado build script are included, but the FPGA implementation/hardware demonstration was not completed.

### ASIC implementation

Yosys synthesis completed and produced `build_asic/riscv_vga_soc.v`. The final routed OpenROAD database, power report, DRC/LVS and GDS were not completed.

## 10. Conclusion

The design demonstrates the required software-to-framebuffer-to-VGA path with CPU-controlled display registers, dual-port framebuffer access, synchronization generation, pixel addressing and RGB output. Directed simulation and the UVM functional regression were completed successfully. FPGA hardware demonstration and full ASIC place-and-route/sign-off remain incomplete and are not claimed as completed results.
