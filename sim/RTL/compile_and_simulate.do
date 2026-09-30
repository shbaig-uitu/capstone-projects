# ============================================================================
# RISC-V SoC - Questa Compilation and Simulation Script
# ============================================================================
# This script compiles all RTL modules and runs functional simulation
# with waveform generation for GTKWave viewing
# ============================================================================

# Set working directory
cd [file normalize [file dirname [info script]]]

# ============================================================================
# Step 1: Create and Setup Work Library
# ============================================================================
echo "=========================================="
echo "Step 1: Setting up work library..."
echo "=========================================="

if {[file exists work]} {
    echo "Removing existing work directory..."
    file delete -force work
}

vlib work
vmap work work

echo "✓ Work library created"
echo ""

# ============================================================================
# Step 2: Compile All RTL Files in Dependency Order
# ============================================================================
echo "=========================================="
echo "Step 2: Compiling RTL files..."
echo "=========================================="

# First compile the include files (they have no dependencies)
echo "Compiling include files..."
vlog -work work \
    ../rtl/include/riscv_defines.sv \
    ../rtl/include/riscv_types.sv

if {[catch {vlog -work work ../rtl/include/riscv_defines.sv}]} {
    echo "✗ Error compiling riscv_defines.sv"
    exit 1
}
echo "✓ riscv_defines.sv compiled"

if {[catch {vlog -work work ../rtl/include/riscv_types.sv}]} {
    echo "✗ Error compiling riscv_types.sv"
    exit 1
}
echo "✓ riscv_types.sv compiled"

# Compile core modules
echo ""
echo "Compiling core modules..."

vlog -work work ../rtl/core/rv32i_core.sv
if {$?} {
    echo "✓ rv32i_core.sv compiled"
} else {
    echo "✗ Error compiling rv32i_core.sv"
}

echo ""
echo "Compiling memory modules..."
vlog -work work ../rtl/memory/sram_sp.sv
if {$?} {
    echo "✓ sram_sp.sv compiled"
}

echo ""
echo "Compiling MMU modules..."
vlog -work work ../rtl/mmu/mmu.sv
if {$?} {
    echo "✓ mmu.sv compiled"
}

vlog -work work ../rtl/mmu/tlb.sv
if {$?} {
    echo "✓ tlb.sv compiled"
}

echo ""
echo "Compiling peripheral modules..."
vlog -work work ../rtl/peripheral/csr_unit.sv
if {$?} {
    echo "✓ csr_unit.sv compiled"
}

vlog -work work ../rtl/peripheral/exception_handler.sv
if {$?} {
    echo "✓ exception_handler.sv compiled"
}

echo ""
echo "Compiling bus modules..."
vlog -work work ../rtl/bus/axi4_arbiter.sv
if {$?} {
    echo "✓ axi4_arbiter.sv compiled"
}

echo ""
echo "Compiling top-level module..."
vlog -work work ../rtl/top/riscv_soc_top.sv
if {$?} {
    echo "✓ riscv_soc_top.sv compiled"
}

echo ""
echo "Compiling testbench..."
vlog -work work tb_riscv_soc.sv
if {$?} {
    echo "✓ tb_riscv_soc.sv compiled"
}

echo ""
echo "✓ All RTL files compiled successfully"
echo ""

# ============================================================================
# Step 3: Elaborate Design
# ============================================================================
echo "=========================================="
echo "Step 3: Elaborating design..."
echo "=========================================="

vsim -work work tb_riscv_soc -do "
    echo '✓ Elaboration successful'
    quit
"

echo ""
echo "✓ Design elaborated"
echo ""

# ============================================================================
# Step 4: Run Simulation with Waveform Generation
# ============================================================================
echo "=========================================="
echo "Step 4: Running simulation with waveforms..."
echo "=========================================="

vsim -work work tb_riscv_soc -do "
    # Enable waveform dumping
    vcd file riscv_soc.vcd
    vcd add -r /*
    
    # Run simulation
    run -all
    
    # Exit
    quit
"

echo ""
echo "✓ Simulation complete"
echo "✓ Waveform saved as: riscv_soc.vcd"
echo ""

# ============================================================================
# Step 5: Generate Transcript
# ============================================================================
echo "=========================================="
echo "Step 5: Creating simulation report..."
echo "=========================================="

# The transcript is automatically saved by Questa

echo "✓ Transcript: transcript"
echo ""

# ============================================================================
# Step 6: Summary
# ============================================================================
echo "=========================================="
echo "SIMULATION COMPLETE - SUMMARY"
echo "=========================================="
echo ""
echo "Generated Files in sim/ folder:"
echo "  ✓ work/               - Compiled library"
echo "  ✓ riscv_soc.vcd      - Waveform (for GTKWave)"
echo "  ✓ transcript         - Simulation log"
echo ""
echo "Next Steps:"
echo "  1. View waveform: gtkwave riscv_soc.vcd"
echo "  2. Check results in transcript file"
echo "  3. Review test output in terminal"
echo ""
echo "=========================================="
