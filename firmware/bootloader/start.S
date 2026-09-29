.section .text.start
.global _start
_start:
    lui sp, 0x00010
    addi sp, sp, -4
    jal ra, main
halt:
    jal x0, halt
