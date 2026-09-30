# RISC-V SoC with Virtual Memory Support

A synthesizable RV32I multicycle SoC whose load/store accesses pass through a simplified virtual-memory subsystem: virtual-to-physical address translation, a 4-entry TLB, a single-level page table, and page-fault reporting. The page table is configured and status is read over an AXI4-Lite interface. Results are shown on LEDs and a UART.

## Features

- RV32I multicycle core: R-type and I-type ALU operations, LW/SW, six branches, JAL, JALR, LUI, AUIPC
- 4 KB instruction SRAM (untranslated fetch) and 4 KB data SRAM (behind the MMU)
- MMU with 4-entry fully-associative TLB (round-robin replacement) and 32-entry single-level page table
- Page-fault handling: write suppressed, read returns `0xDEAD_DEAD`, sticky fault flag latched
- AXI4-Lite slave for page-table programming and status/counter readback
- UART (115200 baud) and LED debug interface
- Directed self-checking testbench, UVM environment, and Arty A7-100T FPGA wrapper

## Address Translation

| Parameter | Value |
|---|---|
| Virtual data address | 13 bits (8 KB): VPN[12:8], offset[7:0] |
| Physical data address | 12 bits (4 KB): PPN[11:8], offset[7:0] |
| Page size | 256 B |
| Virtual pages / physical frames | 32 / 16 |
| Page-table entry | valid (1) + PPN (4) |
| TLB entry | valid (1) + VPN (5) + PPN (4) |

## Memory Map

| Region | Address range |
|---|---|
| Instruction memory (physical) | `0x0000_0000` – `0x0000_0FFF` |
| Data space (virtual) | `0x0000_0000` – `0x0000_1FFF` |
| Data memory (physical) | `0x0000_0000` – `0x0000_0FFF` |
| AXI4-Lite control/status | `0x8000_0000` – `0x8000_00FF` |
| UART/GPIO debug | `0x8000_0100` – `0x8000_01FF` |

## AXI4-Lite Registers (base `0x8000_0000`)

| Offset | Register | Description |
|---|---|---|
| `0x00` | PAGE_TABLE_PROG (W) | bit 0 = valid, bits [4:1] = PPN, bits [9:5] = VPN; commits on write |
| `0x04` | FAULT_STATUS (R/W) | bit 0 = sticky page-fault flag; any write clears it |
| `0x08` | TLB_DEBUG (R) | `{repl_ptr[1:0], entry_valid[3:0]}` |
| `0x0C` | HIT_COUNT (R) | TLB hit counter |
| `0x10` | MISS_COUNT (R) | TLB miss counter |

## Repository Structure

```
rtl/    soc_pkg, tlb, page_table_ctrl, mmu, memories, rv32i_core,
        axi_lite_regs, debug_io, uart_tx, soc_top
tb/     tb_soc_top.sv, asm.py, gen_test_prog.py, test_prog.hex, sim_output.txt
uvm/    agents, env, scoreboard, coverage, assertions, sequences, tests
fpga/   fpga_top.sv, arty.xdc, flow.json, Makefile, test_prog.hex
docs/   architecture.md
```

## Simulation (directed self-checking testbench)

```bash
cd tb
python3 gen_test_prog.py      # regenerates test_prog.hex (optional)
iverilog -g2012 -o sim.out \
  ../rtl/soc_pkg.sv ../rtl/uart_tx.sv ../rtl/tlb.sv ../rtl/page_table_ctrl.sv \
  ../rtl/mmu.sv ../rtl/memories.sv ../rtl/rv32i_core.sv ../rtl/axi_lite_regs.sv \
  ../rtl/debug_io.sv ../rtl/soc_top.sv tb_soc_top.sv
vvp sim.out
```

The testbench programs VPN 0 → PPN 3 over AXI4-Lite, leaves VPN 4 unmapped, runs an 11-instruction program, and checks registers, physical memory, hit/miss counters, and the fault status register (including clear). Expected output ends with `RESULT: ALL CHECKS PASSED` (see `tb/sim_output.txt`). A waveform is written to `tb/sim.vcd`.

## UVM Verification (QuestaSim)

From the project root:

```bash
vlog -sv rtl/soc_pkg.sv rtl/uart_tx.sv rtl/tlb.sv rtl/page_table_ctrl.sv rtl/mmu.sv \
  rtl/memories.sv rtl/rv32i_core.sv rtl/axi_lite_regs.sv rtl/debug_io.sv rtl/soc_top.sv
vlog -sv +incdir+uvm +incdir+uvm/sequences +incdir+uvm/tests +incdir+uvm/assertions \
  -L mtiUvm uvm/tb_uvm_top.sv
vsim -c tb_uvm_top +UVM_TESTNAME=base_test -do "run -all; quit"
```

Available tests: `base_test`, `fault_test`, `rand_test`. The environment contains an AXI agent, an MMU event agent and monitor, a scoreboard, functional coverage (hit/miss/fault × read/write, VPN regions), and SystemVerilog assertions on AXI handshakes and MMU behavior.

## FPGA (Arty A7-100T)

- Part: XC7A100T-CSG324-1, 100 MHz clock, top module `fpga_top`
- `fpga_top` programs VPN 0 → PPN 3 through the AXI4-Lite interface, releases the core, and runs the same program as the testbench

| Signal | Pin | Function |
|---|---|---|
| `clk` | E3 | 100 MHz clock |
| `reset_n` | C2 | Active-low reset |
| `led_fault` | H5 | Page fault |
| `led_hit` | J5 | TLB hit |
| `led_miss` | T9 | TLB miss |
| `led_boot` | T10 | Core running |
| `uart_txd` | D10 | UART TX to host |

Build (with the F4PGA environment loaded so `F4PGA_SHARE` is set):

```bash
cd fpga
make
```

## Design Limitations

- No permission bits; every valid mapping is read/write
- Single-level page table (not two-level Sv32)
- No ASID or multi-process isolation; no TLB shootdown
- Instruction fetches are not translated
- Only LW and SW are implemented for memory access
- Page faults are reported through status registers, LEDs, and UART rather than processor exceptions

## Documentation

See `docs/architecture.md` for the full architecture description.
