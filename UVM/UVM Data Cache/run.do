vlib work
vdel -all
vlib work

# Compile
vlog -sv data_cache.v data_cache_if.sv data_cache_pkg.sv tb_top.sv

# Load simulation
vsim -voptargs="+acc" tb_top +UVM_TESTNAME=data_cache_test

# Add Interface and Internal Waveforms
add wave -position insertpoint sim:/tb_top/vif/*
add wave -position insertpoint sim:/tb_top/dut/*

# Run simulation
run -all
