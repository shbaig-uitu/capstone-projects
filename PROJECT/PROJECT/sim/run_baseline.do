# ============================================================
# run_baseline.do
# QuestaSim script - STEP 1: Baseline compile + simulate
# Dual-Core RV32I SoC (NoC-inspired AHB-Lite interconnect)
# ============================================================

# 1. Create a fresh work library
if {[file exists work]} {
    vdel -all
}
vlib work
vmap work work

# 2. Compile all RTL sources (order does not matter for vlog,
#    Questa resolves module references automatically)
vlog -sv ../rtl/PC.v
vlog -sv ../rtl/Sign_Extend.v
vlog -sv ../rtl/alu.v
vlog -sv ../rtl/rf_32_32.v
vlog -sv ../rtl/Control_Unit.v
vlog -sv ../rtl/Load_Store_Unit.v
vlog -sv ../rtl/instruction_Mem.v
vlog -sv ../rtl/RV32I.v
vlog -sv ../rtl/ahb_lite_adapter.v
vlog -sv ../rtl/address_decoder.v
vlog -sv ../rtl/round_robin_arbiter.v
vlog -sv ../rtl/shared_sram.v
vlog -sv ../rtl/mailbox.v
vlog -sv ../rtl/gpio.v
vlog -sv ../rtl/simple_uart.v
vlog -sv ../rtl/noc_interconnect.v
vlog -sv ../rtl/dual_core_riscv_soc.v

# 3. Compile testbenches
vlog -sv ../tb/tb_noc_interconnect.v
vlog -sv ../tb/tb_dual_core_riscv_soc.v

# ============================================================
# 4. RUN TEST 1: Interconnect-level directed testbench
#    (drives AHB masters directly, no CPU needed)
# ============================================================
vsim work.tb_noc_interconnect
run -all

# ============================================================
# 5. RUN TEST 2: Full SoC-level testbench (both RV32I cores
#    running real programs from prog/core0.txt, prog/core1.txt)
#    NOTE: run this from a directory where core0.txt/core1.txt
#    are visible, or copy them next to the simulation.
# ============================================================
vsim work.tb_dual_core_riscv_soc
run -all
