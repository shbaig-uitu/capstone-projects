OUTPUT_ARCH("riscv")
ENTRY(_start)
MEMORY {
  IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 32K
  DMEM (rw) : ORIGIN = 0x00008000, LENGTH = 32K
}
SECTIONS {
  .text : { *(.text.start) *(.text*) *(.rodata*) . = ALIGN(4); } > IMEM
  .data : { *(.data*) *(.sdata*) . = ALIGN(4); } > DMEM
  .bss : { *(.bss*) *(.sbss*) *(COMMON) . = ALIGN(4); } > DMEM
  _stack_top = ORIGIN(DMEM) + LENGTH(DMEM);
}
