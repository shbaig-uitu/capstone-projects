PHONY := audit test wave frames uvm firmware fpga asic pd clean help

.PHONY: $(PHONY)

help:
	@echo "Project 02 - RV32I SoC + VGA"
	@echo "  make audit     : check project structure and installed tools"
	@echo "  make test     : run portable Icarus directed regression"
	@echo "  make wave     : run directed regression and open GTKWave"
	@echo "  make uvm      : run Questa/UVM regression"
	@echo "  make firmware : rebuild firmware.hex"
	@echo "  make fpga     : Vivado synthesis/implementation for Arty A7-100T"
	@echo "  make asic     : generic Yosys synthesis handoff"
	@echo "  make pd       : OpenROAD flow (requires assigned PDK)"

audit:
	bash ./scripts/project_audit.sh

test: sim/output
	bash ./scripts/run_iverilog.sh

wave: test
	@if command -v gtkwave >/dev/null 2>&1; then gtkwave sim/output/riscv_vga_soc.vcd; else echo "GTKWave not found. VCDs are in sim/output/."; fi

frames:
	bash ./scripts/capture_frames.sh

uvm:
	bash ./scripts/run_uvm.sh

firmware:
	$(MAKE) -C firmware all

fpga:
	bash ./scripts/build_fpga.sh

asic:
	bash ./scripts/build_asic.sh

pd:
	./physical_design/openroad/run_pd.sh

clean:
	rm -rf work transcript sim/output sim/logs build vivado_project build_asic uvm/work uvm/transcript uvm/*.ucdb uvm/reports
	$(MAKE) -C firmware clean || true

sim/output:
	mkdir -p $@
