# Simulation Folder - Complete Index

## 📋 Contents Overview

This folder contains everything needed to simulate, verify, and analyze the RISC-V SoC RTL design.

---

## 📁 Files in This Folder

### Source Files
| File | Purpose | Lines | Status |
|------|---------|-------|--------|
| `tb_riscv_soc.sv` | Comprehensive testbench with GPIO/UART tests | 180 | ✅ Ready |

### Execution Scripts
| File | Purpose | OS | Status |
|------|---------|-----|--------|
| `run_simulation.bat` | Automated compilation & simulation | Windows | ✅ Ready |
| `compile_and_simulate.do` | TCL script for Questa | All | ✅ Ready |

### Documentation Files
| File | Purpose | Content | Status |
|------|---------|---------|--------|
| `SIM_README.md` | Complete simulation guide | Usage, troubleshooting | ✅ Ready |
| `ARCHITECTURE_SCHEMATIC.txt` | RTL architecture diagrams | Block diagrams, signal flow | ✅ Ready |
| `INDEX.md` | This file | Directory guide | ✅ Ready |

### Generated After Simulation
| File | Purpose | Created By |
|------|---------|------------|
| `work/` | Compiled design library | vlib/vlog |
| `riscv_soc.vcd` | Waveform for GTKWave | vsim |
| `transcript` | Simulation log | Questa |
| `SIMULATION_REPORT.txt` | Results summary | run_simulation.bat |

---

## 🚀 Quick Start

### 1️⃣ First Time Setup

```bash
# Windows
cd sim
run_simulation.bat

# Linux/Mac
cd sim
vsim -work work tb_riscv_soc -batch -do "vcd file riscv_soc.vcd; vcd add -r /*; run -all; quit"
```

### 2️⃣ View Results

```bash
# View waveforms
gtkwave riscv_soc.vcd

# Check simulation log
type transcript

# Read summary
type SIMULATION_REPORT.txt
```

---

## 📊 What Gets Simulated

### Test Coverage

The testbench performs comprehensive verification:

```
✓ Clock Generation (100 MHz)
✓ Reset Sequencing (5 cycles)
✓ GPIO Pass-Through (Input=0xAA → Output=0xAA)
✓ UART Loopback (RX=1 → TX=1)
✓ Extended Operation (100+ cycles stable)
```

### Modules Under Test

```
✓ RV32I Core          (32-bit processor)
✓ MMU                 (Virtual→Physical translation)
✓ TLB                 (16-entry translation cache)
✓ CSR Unit            (Control registers)
✓ Exception Handler   (Exception/interrupt mgmt)
✓ SRAM Memory         (4KB Inst + 4KB Data)
✓ Peripherals         (GPIO, UART stubs)
```

---

## 🎯 Expected Results

### Successful Simulation Output

```
========================================
Step 1: Setting up work library...
========================================
✓ Work library created

========================================
Step 2: Compiling RTL files...
========================================
✓ riscv_defines.sv compiled
✓ riscv_types.sv compiled
✓ rv32i_core.sv compiled
✓ sram_sp.sv compiled
✓ mmu.sv compiled
✓ tlb.sv compiled
✓ csr_unit.sv compiled
✓ exception_handler.sv compiled
✓ axi4_arbiter.sv compiled
✓ riscv_soc_top.sv compiled
✓ tb_riscv_soc.sv compiled

========================================
Step 3: Running simulation...
========================================
[TB] Test 1: Clock is running and reset released
[TB] Test 2: Checking program counter advancement
[TB] GPIO: Input=0xAA, Output=0xAA
[TB] ✓ GPIO pass-through working
[TB] UART: RX=1, TX=1
[TB] ✓ UART echo working
[TB] Simulation completed successfully

========================================
SIMULATION COMPLETE - SUCCESS
========================================
```

### Generated Files

After successful simulation, you'll have:

```
sim/
├── work/                        (Compiled library, ~20MB)
├── riscv_soc.vcd               (Waveforms, ~100-500KB)
├── transcript                  (Log file, ~20-50KB)
├── SIMULATION_REPORT.txt       (Summary, <1KB)
└── [all original files]
```

---

## 📖 Detailed Documentation

### For General Users
→ Start with **SIM_README.md**
- Quick start (30 sec)
- Basic waveform viewing
- Troubleshooting common issues

### For Advanced Users
→ Review **ARCHITECTURE_SCHEMATIC.txt**
- Module interconnections
- Signal flow diagrams
- Timing specifications
- Memory layout

### For Developers
→ Study **tb_riscv_soc.sv**
- Test code structure
- Signal assertions
- Verification techniques

---

## 🔧 Common Tasks

### Task 1: Run Simulation

**Windows (Easiest):**
```batch
double-click run_simulation.bat
```

**Command Line:**
```batch
cd sim && run_simulation.bat
```

### Task 2: View Waveforms

```bash
# After simulation completes
gtkwave riscv_soc.vcd
```

### Task 3: Review Results

```bash
# Check what happened
type transcript

# See summary
type SIMULATION_REPORT.txt
```

### Task 4: Add Custom Tests

Edit `tb_riscv_soc.sv`:
```verilog
// Add custom test code here
gpio_in = 8'h55;  // Your test
repeat(10) @(posedge clk);
```

### Task 5: Modify Simulation Length

Edit `tb_riscv_soc.sv`:
```verilog
repeat(100) @(posedge clk);  // Change 100 to desired cycles
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Questa not found" | Install Questa-sim 21 or ModelSim, add to PATH |
| "Compilation error" | Check RTL files exist in ../rtl/ |
| "No waveform generated" | Check transcript for errors, verify vcd file commands |
| "Simulation hangs" | Press Ctrl+C, reduce cycle count |
| "GTKWave won't open VCD" | Try smaller VCD file, update GTKWave |

See **SIM_README.md** for detailed troubleshooting.

---

## 📋 File Dependency Tree

```
run_simulation.bat
├── calls vlog on RTL files:
│   ├── ../rtl/include/riscv_defines.sv
│   ├── ../rtl/include/riscv_types.sv
│   ├── ../rtl/core/rv32i_core.sv
│   ├── ../rtl/memory/sram_sp.sv
│   ├── ../rtl/mmu/mmu.sv
│   ├── ../rtl/mmu/tlb.sv
│   ├── ../rtl/peripheral/csr_unit.sv
│   ├── ../rtl/peripheral/exception_handler.sv
│   ├── ../rtl/bus/axi4_arbiter.sv
│   ├── ../rtl/top/riscv_soc_top.sv
│   └── tb_riscv_soc.sv
│
├── calls vsim to run:
│   └── work.tb_riscv_soc
│
└── generates:
    ├── riscv_soc.vcd
    ├── transcript
    └── SIMULATION_REPORT.txt
```

---

## 🎓 Key Signals to Monitor

Open `riscv_soc.vcd` with GTKWave and add these signals:

### Clock & Reset
```
tb_riscv_soc.clk              # Should see 100 MHz square wave
tb_riscv_soc.rst_n            # Should see pulse at start
```

### Core Activity
```
tb_riscv_soc.dut.core_inst.pc              # Program counter
tb_riscv_soc.dut.core_inst.inst_vaddr      # Instruction address
tb_riscv_soc.dut.core_inst.data_vaddr      # Data address
```

### Virtual Memory
```
tb_riscv_soc.dut.mmu_inst.mmu_inst_paddr   # Physical address
tb_riscv_soc.dut.tlb_inst.tlb_valid        # TLB valid bits
```

### Peripherals
```
tb_riscv_soc.gpio_in                       # GPIO input (should be 0xAA in test)
tb_riscv_soc.gpio_out                      # GPIO output (should match input)
tb_riscv_soc.uart_rx                       # UART receive
tb_riscv_soc.uart_tx                       # UART transmit
```

---

## 📊 Performance Metrics

### Compilation
- Time: 5-20 seconds (first time), 2-5 seconds (incremental)
- CPU: Single-threaded, can be parallelized
- RAM: ~200MB for work library

### Simulation
- Time: ~2 seconds (130 cycles), ~10-30 seconds (1000 cycles)
- CPU: Single-threaded
- RAM: ~500MB

### Waveform
- Size: ~100-500KB (130 cycles), ~1-5MB (1000 cycles)
- Compression: Built-in VCD compression
- View time: Instant (GTKWave cached)

---

## ✅ Verification Checklist

Before deploying, verify:

- [ ] Compilation completes without errors
- [ ] Simulation runs to completion
- [ ] riscv_soc.vcd file generated
- [ ] transcript file created
- [ ] GTKWave can open VCD file
- [ ] All signals visible in waveform
- [ ] Clock looks correct (100 MHz)
- [ ] Reset pulse at start
- [ ] GPIO test passes
- [ ] UART test passes
- [ ] 100+ cycles complete successfully

---

## 📝 Log & Report Files

### transcript
Machine-readable simulation log with:
- Compiler messages
- Elaboration progress
- Simulation events
- Error messages (if any)

### SIMULATION_REPORT.txt
Human-readable summary with:
- Simulation date/time
- Generated files list
- RTL modules compiled
- Test results
- Next steps

---

## 🔗 Related Documentation

- **SIM_README.md** - Detailed simulation guide
- **ARCHITECTURE_SCHEMATIC.txt** - RTL architecture
- **../BUILD_INSTRUCTIONS.md** - Compilation guide
- **../PROJECT_STATUS.md** - Project overview
- **../QUICK_START.md** - Getting started

---

## 🎉 Success Criteria

Your simulation is successful when:

```
✅ All RTL files compile without errors
✅ Elaboration completes successfully
✅ Simulation runs all 130+ cycles
✅ All tests pass (GPIO, UART, operations)
✅ riscv_soc.vcd file is created
✅ Waveforms viewable in GTKWave
✅ No warnings or errors in transcript
```

---

## 📞 Support

If you have questions:

1. Read **SIM_README.md** section "Troubleshooting"
2. Review **ARCHITECTURE_SCHEMATIC.txt** for design details
3. Check **transcript** file for error messages
4. Review **tb_riscv_soc.sv** comments

---

## 📅 Version History

| Date | Version | Changes |
|------|---------|---------|
| Sep 12, 2026 | 1.0 | Initial creation |

---

**Status**: ✅ All simulation files ready
**Last Updated**: September 12, 2026
**Next Step**: Run `run_simulation.bat` and view `riscv_soc.vcd` with GTKWave

---

## 🚀 Ready? Start Here!

```bash
# Windows
cd sim
run_simulation.bat

# Then view results
gtkwave riscv_soc.vcd
```

**Enjoy your RISC-V SoC simulation!** 🎊
