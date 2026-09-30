# RV32I SoC with Simplified Virtual Memory — Architecture

## 1. Scope (confirmed)

- **Data accesses only are translated.** Load/Store (LW/SW) addresses go
  through the MMU (TLB + page table). **Instruction fetch is untranslated**
  (direct physical addressing) — this avoids needing exception/trap
  redirection of the PC, which is explicitly out of scope for this project.
- Single-level, unified page table. No permission bits (R/W/X), no ASID /
  process isolation, no multi-level paging, no TLB shootdown. These are
  named limitations, not oversights — see Section 6.

## 2. Memory map

| Region | Address range | Size | Notes |
|---|---|---|---|
| Instruction memory (physical) | `0x0000_0000` – `0x0000_0FFF` | 4 KB | Untranslated, addressed directly by PC |
| Data memory — virtual space | `0x0000_0000` – `0x0000_1FFF` | 8 KB (13-bit VA) | What LW/SW addresses mean, as seen by the core |
| Data memory — physical space | `0x0000_0000` – `0x0000_0FFF` | 4 KB (12-bit PA) | Real backing SRAM behind the MMU |
| Page table (internal) | — | 32 entries | Register array inside the page-table controller, not memory-mapped |
| AXI4-Lite control/status regs | `0x8000_0000` – `0x8000_00FF` | — | Page-table programming, fault status, TLB stats |
| UART/GPIO debug | `0x8000_0100` – `0x8000_01FF` | — | Pass/fail indication on FPGA |

## 3. Address translation parameters

- Virtual data address width: **13 bits** (8 KB space)
- Physical data address width: **12 bits** (4 KB space)
- Page size: **256 B** → 8-bit page offset
- Virtual Page Number (VPN): **5 bits** → 32 possible virtual pages
- Physical Page Number (PPN): **4 bits** → 16 possible physical pages

```
Virtual address (13 bits):   [ VPN (5) | Offset (8) ]
Physical address (12 bits):  [ PPN (4) | Offset (8) ]
```

Because there are 32 virtual pages but only 16 physical page frames, at
most half the virtual address space can be mapped at any time — this is
what makes valid translations, TLB misses, and page faults all reachable
with a short test program.

## 4. Page table entry (PTE) format

Each of the 32 page-table entries is a small register:

| Field | Width | Meaning |
|---|---|---|
| `valid` | 1 bit | 1 = this VPN has a mapping, 0 = unmapped → page fault |
| `ppn` | 4 bits | Physical page number this VPN maps to (only meaningful if valid) |

Total PTE width: 5 bits. 32 entries × 5 bits fits trivially in a register
file — easy to preload, inspect on FPGA/waveform, and reason about.

## 5. TLB

- **4-entry, fully associative.**
- Each entry: `valid (1) | vpn (5) | ppn (4)` = 10 bits.
- Replacement policy: simple round-robin (2-bit pointer) — deterministic
  and easy to verify, no need for true LRU for a 4-entry TLB in a teaching
  project.
- On every data access: all 4 entries' VPNs are compared in parallel
  against the incoming VPN. A match on a valid entry = **hit**. No match =
  **miss**, which triggers a page-table lookup and a TLB fill.

## 6. Translation flow (data access)

```
CPU issues LW/SW with 13-bit virtual address
        │
        ▼
  Split into VPN[12:8] and Offset[7:0]
        │
        ▼
   TLB lookup (compare VPN against all 4 entries)
        │
   ┌────┴────┐
  HIT       MISS
   │          │
   │          ▼
   │   Page-table lookup using VPN (1-cycle, since it's a
   │   register-file read — no real "walk" needed for a
   │   single-level table)
   │          │
   │     ┌────┴────┐
   │  VALID     INVALID
   │     │           │
   │     ▼           ▼
   │  Fill TLB    Raise page_fault status bit,
   │  (round-     do NOT access physical memory,
   │   robin)     LED/UART reports FAULT
   │     │
   ▼     ▼
  Form physical address = {PPN, Offset}
  Access physical data SRAM (read for LW, write for SW)
  LED/UART reports OK
```

## 7. Fault handling model (simplified, no exceptions)

On an invalid mapping:
- The memory access does **not** complete (write is suppressed; read
  returns a defined "fault" value, e.g. `32'hDEAD_DEAD`).
- A `page_fault` status bit is latched in a status register (readable over
  AXI4-Lite, and drives a debug LED).
- The core is **not** interrupted or redirected — the test program simply
  continues to its next instruction. This is the deliberate simplification
  that avoids needing trap/exception hardware.

## 8. Main modules

1. `rv32i_core` — multicycle RV32I core (instruction fetch is
   untranslated; LW/SW go out through the MMU interface).
2. `instr_mem` — 4 KB physical instruction SRAM.
3. `data_mem` — 4 KB physical data SRAM (behind the MMU).
4. `tlb` — 4-entry fully-associative TLB.
5. `page_table_ctrl` — 32-entry page table + lookup logic.
6. `mmu` — glues `tlb` + `page_table_ctrl` together, presents one
   translation interface to the core, generates fault status.
7. `axi_lite_regs` — AXI4-Lite slave: lets a host (or startup logic)
   program the page table, and exposes fault/TLB-stat status registers.
8. `debug_io` — drives UART text + LEDs from MMU status for the FPGA demo.
9. `soc_top` — wires everything together.

## 9. Named limitations (for project defense)

- No permission bits — every valid mapping is implicitly read+write.
- No multi-level page table — real Sv32 (RISC-V's standard MMU) uses a
  2-level walk; ours is a single flat table because our address space is
  tiny.
- No ASID / multi-process isolation — only one running program is modeled.
- No TLB shootdown / coherence — irrelevant with a single core.
- Instruction fetches are not translated — avoids needing exception/trap
  redirection of the PC, which the project spec excludes.

These are stated up front deliberately: they are scoped-out complexity,
not bugs.
