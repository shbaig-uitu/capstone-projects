transcript on
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

set ROOT [file normalize [pwd]]
if {[info exists ::env(UVM_HOME)]} {
    set UVM_HOME $::env(UVM_HOME)
} elseif {[info exists ::env(QUESTA_HOME)]} {
    set UVM_HOME [file join $::env(QUESTA_HOME) verilog_src uvm-1.2]
} else {
    puts "ERROR: Set UVM_HOME to your Questa UVM installation."
    quit -code 2
}

vlog -sv -cover bcestf +define+SIMULATION +incdir+$UVM_HOME/src \
  $UVM_HOME/src/uvm_pkg.sv \
  $ROOT/rtl/peripherals/duck_animation.v \
  $ROOT/rtl/peripherals/vga_timing.v \
  $ROOT/rtl/peripherals/pixel_address_gen.v \
  $ROOT/rtl/peripherals/rgb_output.v \
  $ROOT/rtl/peripherals/vga_controller.v \
  $ROOT/rtl/peripherals/axi_lite_vga_regs.v \
  $ROOT/uvm/axi_lite_if.sv \
  $ROOT/uvm/native_mem_if.sv \
  $ROOT/rtl/interconnect/mem_interconnect.v \
  $ROOT/rtl/peripherals/framebuffer_ram.v \
  $ROOT/uvm/vga_uvm_pkg.sv \
  $ROOT/uvm/vga_assertions.sv \
  $ROOT/uvm/tb_uvm_vga.sv

vsim -c -nocvg -coverage -sv_lib $ROOT/uvm/dpi_lib/libuvm_dpi work.tb_uvm_vga +UVM_TESTNAME=vga_uvm_test
run -all
coverage save -onexit $ROOT/uvm/uvm_coverage.ucdb
quit -f
