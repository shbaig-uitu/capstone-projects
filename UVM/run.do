
vdel -lib work -all
vlib work
vmap work work

# ==========================================
# RTL COMPILE
# ==========================================
vlog noc_interconnect.v
vlog shared_data_memory.v
vlog mailbox_reg.v
vlog baud_rate_generator.v
vlog uart_tx.v
vlog uart_rx.v
vlog axi_uart_slave.v
vlog axi_lite_master_bridge.v
vlog axi_uart_system.v
vlog mailbox_system.v

# ==========================================
# UVM COMPILE
# ==========================================

# Interface must be compiled before package
vlog -sv core_if_uvm.sv

# Package includes all UVM classes
vlog -sv soc_uvm_pkg.sv

# Top compiled last
vlog -sv tb_top_uvm.sv

# ==========================================
# SIMULATION
# ==========================================
vsim -voptargs=+acc work.tb_top_uvm

add wave -r sim:/tb_top_uvm/*

run -all