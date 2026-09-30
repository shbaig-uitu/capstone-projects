# RISC-V SoC Simulation Guide

## Overview

This directory contains all simulation-related files and scripts for the RISC-V SoC project.

---

## Quick Start (30 seconds)

### Windows:
```batch
cd sim
run_simulation.bat
```

### Linux/Mac:
```bash
cd sim
vsim -work work tb_riscv_soc -batch -do "vcd file riscv_soc.vcd; vcd add -r /*; run -all; quit"
```

---

## Files in This Directory

### Source Files
- `tb_riscv_soc.sv` - Complete testbench with all tests

### Simulation Scripts
- `run_simulation.bat` - Windows batch script (recommended for Windows)
- `compile_and_simulate.do` - Questa TCL script (for manual control)

### Generated Files (after simulation)
- `work/` - Compiled RTL library
- `riscv_soc.vcd` - Waveform file (for GTKWave)
- `transcript` - Simulation log
- `SIMULATION_REPORT.txt` - Summary report

---

## Detailed Instructions

### Step 1: Run Simulation (Windows)

**Method 1: Automatic (Recommended)**
```batch
double-click run_simulation.bat
```

**Method 2: Command Line**
```batch
cd sim
run_simulation.bat
```

### Step 2: View Waveforms

After simulation completes, view waveforms with GTKWave:

```bash
gtkwave riscv_soc.vcd
```

Or from the sim folder:
```bash
gtkwave riscv_soc.vcd &
```

### Step 3: Review Results

Check simulation transcript:
```bash
type transcript
```

Check simulation report:
```bash
type SIMULATION_REPORT.txt
```

---

## What Gets Simulated

### Testbench Tests

The testbench (`tb_riscv_soc.sv`) performs:

1. **Clock Generation**
   - 100 MHz clock (10ns period)
   - Runs for 130+ cycles

2. **Reset Sequence**
   - Holds reset for 5 cycles
   - Releases reset
   - Verifies clean startup

3. **GPIO Pass-Through Test**
   - Sets gpio_in = 0xAA
   - Verifies gpio_out = 0xAA
   - Status: ✓ Pass

4. **UART Loopback Test**
   - Sets uart_rx = 1
   - Verifies uart_tx = 1
   - Status: ✓ Pass

5. **Extended Operation**
   - Runs for 100+ additional cycles
   - Verifies stable operation
   - Status: ✓ Pass

---

## Waveform Viewing Guide

### GTKWave Shortcuts

| Action | Shortcut |
|--------|----------|
| Zoom in | `+` |
| Zoom out | `-` |
| Fit to window | `Shift+F` |
| Scroll left | `Left arrow` |
| Scroll right | `Right arrow` |
| Add signal | Drag from tree to waveform |
| Search signal | `Ctrl+F` |

### Important Signals to Monitor

```
tb_riscv_soc.clk              - Clock signal (100 MHz)
tb_riscv_soc.rst_n            - Reset (active low)
tb_riscv_soc.dut.clk          - DUT clock
tb_riscv_soc.dut.rst_n        - DUT reset

Core Signals:
tb_riscv_soc.dut.core_inst.pc              - Program counter
tb_riscv_soc.dut.core_inst.inst_vaddr      - Inst address
tb_riscv_soc.dut.core_inst.data_vaddr      - Data address

Memory:
tb_riscv_soc.dut.mmu_inst.mmu_inst_paddr   - Physical address
tb_riscv_soc.dut.inst_mem.mem              - Inst memory contents
tb_riscv_soc.dut.data_mem.mem              - Data memory contents

CSR:
tb_riscv_soc.dut.csr_inst.satp             - SATP register
tb_riscv_soc.dut.csr_inst.mcycle           - Cycle counter

TLB:
tb_riscv_soc.dut.tlb_inst.tlb_valid        - TLB valid bits

Peripherals:
tb_riscv_soc.gpio_in/gpio_out              - GPIO signals
tb_riscv_soc.uart_rx/uart_tx               - UART signals
```

---

## Expected Results

### Console Output
```
[TB] Test 1: Clock is running and reset released
[TB] Test 2: Checking program counter advancement
[TB] After 20 cycles - Design running
[TB] GPIO: Input=0xAA, Output=0xAA
[TB] ✓ GPIO pass-through working
[TB] UART: RX=1, TX=1
[TB] ✓ UART echo working
[TB] Test 5: Extended simulation
[TB] Simulation completed successfully
```

### Generated Files

#### riscv_soc.vcd (Waveform)
- Compressed binary file
- Contains all signal values over time
- Viewable in GTKWave
- File size: ~100-500 KB depending on simulation length

#### transcript
- Human-readable simulation log
- Shows all compiler messages
- Simulation progress
- Test results
- File size: ~10-50 KB

#### SIMULATION_REPORT.txt
- Executive summary
- List of generated files
- Test results
- Next steps

---

## Troubleshooting

### Problem: "Questa not found in PATH"
**Solution**: 
- Install Questa-sim 21 or ModelSim
- Add installation bin directory to Windows PATH
- Test: Open new command prompt, type `qverilog --version`

### Problem: "Error compiling RTL"
**Solution**:
- Check file paths (should be relative to sim directory)
- Verify all .sv files exist in rtl/ folder
- Try manual compilation: `vlog -work work ../rtl/include/riscv_defines.sv`

### Problem: "No waveform generated"
**Solution**:
- Check transcript for errors during simulation
- Verify riscv_soc.vcd exists: `dir riscv_soc.vcd`
- Ensure `vcd file` and `vcd add` commands are in script

### Problem: "GTKWave crashes when opening VCD"
**Solution**:
- Verify VCD file size: `dir /s riscv_soc.vcd`
- Try with smaller simulation (reduce cycle count in testbench)
- Update GTKWave to latest version

### Problem: "Simulation hangs"
**Solution**:
- Check if infinite loop in testbench
- Press Ctrl+C to stop
- Review testbench finite length (should be ~200 cycles max)

---

## Advanced Usage

### Increase Simulation Length

Edit `tb_riscv_soc.sv`, change:
```verilog
repeat(100) @(posedge clk);  // Change 100 to larger number
```

### Add More Signals to VCD

Edit `run_simulation.bat`, modify:
```
vcd add -r /*
```
To:
```
vcd add /tb_riscv_soc/*
vcd add /tb_riscv_soc/dut/*
vcd add /tb_riscv_soc/dut/core_inst/*
```

### Save Waveforms with Timestamp

Edit `run_simulation.bat`:
```batch
set TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
vcd file riscv_soc_%TIMESTAMP%.vcd
```

### Generate SAIF (Switching Activity)

Add to simulation script:
```
saif file riscv_soc.saif
saif add -r /*
```

---

## Performance Notes

### Compilation Time
- First compilation: ~10-20 seconds
- Incremental (after changes): ~2-5 seconds
- Depends on machine speed

### Simulation Time
- Testbench (130 cycles): ~1-2 seconds
- Long simulations (1000+ cycles): ~10-30 seconds

### File Sizes
- work/ library: 10-50 MB
- VCD (130 cycles): 100-500 KB
- VCD (1000 cycles): 1-5 MB

---

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: Simulate RISC-V SoC
on: [push, pull_request]
jobs:
  simulate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Questa
        run: # (installation steps)
      - name: Run simulation
        working-directory: sim
        run: vsim -work work tb_riscv_soc -batch -do "vcd file riscv_soc.vcd; vcd add -r /*; run -all; quit"
      - name: Upload waveforms
        uses: actions/upload-artifact@v2
        with:
          name: simulation-results
          path: sim/riscv_soc.vcd
```

---

## Documentation Files

For more information, see:
- `BUILD_INSTRUCTIONS.md` - Compilation guide
- `PROJECT_STATUS.md` - Project overview
- `QUICK_START.md` - Getting started
- `CHANGES_SUMMARY.md` - What was fixed

---

## Contact & Support

For questions:
1. Check this README
2. Review testbench comments in `tb_riscv_soc.sv`
3. Check `transcript` for compilation errors
4. Review `SIMULATION_REPORT.txt` for test results

---

## Revision History

| Date | Version | Changes |
|------|---------|---------|
| Sep 12, 2026 | 1.0 | Initial creation |

---

**Status**: ✅ Ready for simulation
**Last Updated**: September 12, 2026
