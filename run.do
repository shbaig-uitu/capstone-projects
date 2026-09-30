vlib work
vmap work work

# 1. RTL files from Capstone
vlog -sv C:/Users/dell/Downloads/capstone/capstone/pe.sv \
         C:/Users/dell/Downloads/capstone/capstone/systolic_4x4.sv \
         C:/Users/dell/Downloads/capstone/capstone/accelerator_top.sv

# 2. UVM TB files from current folder
vlog -sv axi_if.sv systolic_pkg.sv tb_top.sv

# 3. Simulate and Run
vsim -voptargs="+acc" tb_top +UVM_TESTNAME=systolic_base_test
run -all