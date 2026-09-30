# Clean and create work library
vdel -all
vlib work

# Compile
vlog -reportprogress 300 -sv +incdir+. \
    shared_mem.v \
    shared_mem_if.sv \
    shared_mem_pkg.sv \
    tb_top.sv

# Load simulation
vsim -voptargs=+acc work.tb_top +UVM_TESTNAME=shared_mem_test

# Add Interface Waveforms
add wave -position insertpoint sim:/tb_top/vif/*

# Add DUT/Internal Waveforms
add wave -position insertpoint sim:/tb_top/dut/*

# Run simulation
run -all
