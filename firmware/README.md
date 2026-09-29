# Firmware

The firmware boots from `0x00000000`, initializes the 640x480 RGB332 framebuffer to `0x9F`, then enables the VGA display and animation through the memory-mapped register block.

## Software map

```text
0x00000000  Instruction SRAM
0x00008000  Data SRAM
0x00010000  640x480x8 framebuffer
0x10000000  VGA control/status registers
```

`firmware/firmware.hex` is checked in so simulation can run without a RISC-V compiler. Rebuild with `make all` when the `riscv32-none-elf-*` toolchain is installed.
