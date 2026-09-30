vlib work
vdel -all
vlib work

# Compile
vlog -sv ahb_arbiter.v ahb_decoder.v TOPMODULE.v REGISTER_FILE.v PC.v CONTROL_UNIT.v ALU.v WRAPPER_MEM.v DATA_MEM.v if_id_reg.v id_ex_reg.v ex_mem_reg.v mem_wb_reg.v riscv_if.sv riscv_pkg.sv tb_top.sv

# Load simulation
vsim -voptargs="+acc" tb_top +UVM_TESTNAME=riscv_test

# Add Interface and Internal Waveforms
add wave -position insertpoint sim:/tb_top/vif/*
add wave -position insertpoint sim:/tb_top/u_dut/*

# Run simulation
run -all
