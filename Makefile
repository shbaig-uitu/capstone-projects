ifndef F4PGA_SHARE
$(error F4PGA_SHARE not set. Load your university F4PGA environment first.)
endif

TOP := fpga_top
XDC := arty.xdc

.PHONY: all build clean

all: build

# The FPGA wrapper boots the same program used by the verified testbench.
# Keep a local copy so the synthesized instruction memory can find it.
test_prog.hex: ../tb/test_prog.hex
	cp ../tb/test_prog.hex ./test_prog.hex

build: test_prog.hex
	f4pga -vv build \
		--flow ./flow.json \
		--target bitstream

clean:
	rm -rf build
	rm -f synth.log
	rm -f pack.log
	rm -f *.fasm
	rm -f *.bit
	rm -f test_prog.hex
	rm -f .f4cache
