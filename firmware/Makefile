# Bare-metal RV32I firmware build.
# Default program is main.c, which matches the required VGA register map.

CROSS_COMPILE ?= riscv32-none-elf-
CC       = $(CROSS_COMPILE)gcc
OBJCOPY  = $(CROSS_COMPILE)objcopy
OBJDUMP  = $(CROSS_COMPILE)objdump
SIZE     = $(CROSS_COMPILE)size

ARCH_FLAGS = -march=rv32i -mabi=ilp32
CFLAGS  = $(ARCH_FLAGS) -O2 -Wall -Wextra -ffreestanding -nostdlib
ASFLAGS = $(ARCH_FLAGS)
LDFLAGS = -T linker.ld -nostdlib -nostartfiles

BUILD_DIR = build
ELF = $(BUILD_DIR)/firmware.elf
BIN = $(BUILD_DIR)/firmware.bin
HEX = $(BUILD_DIR)/firmware.hex
LST = $(BUILD_DIR)/firmware.lst

OBJS = $(BUILD_DIR)/start.o $(BUILD_DIR)/main.o

.PHONY: all clean size help sync-hex

all: $(BIN) $(HEX) $(LST) size sync-hex

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/start.o: bootloader/start.S | $(BUILD_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/main.o: main.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(ELF): $(OBJS) linker.ld
	$(CC) $(LDFLAGS) $(OBJS) -o $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(HEX): $(ELF)
	$(OBJCOPY) -O verilog $< $@

$(LST): $(ELF)
	$(OBJDUMP) -d $< > $@

size: $(ELF)
	@echo "=== Firmware Size ==="
	@$(SIZE) $<

sync-hex: $(HEX)
	cp -f $(HEX) firmware.hex
	python3 ../scripts/pad_hex.py firmware.hex 8192

clean:
	rm -rf $(BUILD_DIR)

help:
	@echo "make all   - build the VGA firmware"
	@echo "make clean - remove build directory"
	@echo "Toolchain: $(CC)"
