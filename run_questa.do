transcript on
set ROOT [file normalize [file dirname [info script]]]
cd $ROOT
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
file mkdir sim/output
file mkdir sim/logs

vlog -sv -cover bcestf +define+SIMULATION \
  rtl/core/rv32i_core.v \
  rtl/peripherals/block_ram.v \
  rtl/peripherals/framebuffer_ram.v \
  rtl/peripherals/duck_animation.v \
  rtl/peripherals/vga_timing.v \
  rtl/peripherals/pixel_address_gen.v \
  rtl/peripherals/rgb_output.v \
  rtl/peripherals/vga_controller.v \
  rtl/peripherals/axi_lite_vga_regs.v \
  rtl/interconnect/mem_interconnect.v \
  rtl/top/riscv_vga_soc.v \
  sim/system/tb_rv32i_core.sv \
  sim/system/tb_axi_lite_vga_regs.sv \
  sim/system/tb_mem_interconnect.sv \
  sim/system/tb_duck_animation.sv \
  sim/system/tb_vga_controller.sv \
  sim/system/tb_riscv_vga_soc.sv

foreach tb {
  tb_rv32i_core
  tb_axi_lite_vga_regs
  tb_mem_interconnect
  tb_duck_animation
  tb_vga_controller
  tb_riscv_vga_soc
} {
  puts "--- Running $tb ---"
  vsim -c -voptargs=+acc work.$tb
  run -all
  quit -sim
}

puts "Questa directed regression completed."
quit -f
