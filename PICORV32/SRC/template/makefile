TOOLCHAIN_PREFIX := riscv32-unknown-elf-
PYTHON := python

CFLAGS := -ffreestanding -nostdlib -mabi=ilp32 -march=rv32i
CC := $(TOOLCHAIN_PREFIX)gcc

LIB_DIR := ../lib/
BUILDDIR := build/

SOURCES_C := $(wildcard *.c)
SOURCES_S := $(wildcard *.s)
SOURCES_LIB := $(wildcard $(LIB_DIR)*.c)
OBJECTS_LIB := $(patsubst ../lib/%.c, $(BUILDDIR)%.o, $(SOURCES_LIB))
FIRMWARE_OBJS := $(patsubst %.c, $(BUILDDIR)%.o, $(SOURCES_C))
FIRMWARE_OBJS += $(patsubst %.s, $(BUILDDIR)%.o, $(SOURCES_S))
FIRMWARE_OBJS += $(OBJECTS_LIB)

FIRMWARE_IMAGE := $(BUILDDIR)firmware.elf
FIRMWARE_BIN := $(BUILDDIR)firmware.bin
FIRMWARE_HEX := $(BUILDDIR)firmware.hex

$(info $(SOURCES))
$(info $(FIRMWARE_OBJS))
$(info $(LIB_DIR))

.PHONY: clean

$(FIRMWARE_HEX): $(FIRMWARE_BIN)
	$(PYTHON) makehex.py $< 1024 > firmware.hex

$(FIRMWARE_BIN): $(FIRMWARE_IMAGE)
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

$(FIRMWARE_IMAGE): $(FIRMWARE_OBJS)
	$(CC) -Os -mabi=ilp32 -march=rv32i -ffreestanding -nostdlib -o $@ \
		-Wl,--build-id=none,-Bstatic,-T,sections.lds,--strip-debug \
		$(FIRMWARE_OBJS) -lgcc
	
$(BUILDDIR)%.o: %.c
	if not exist build (mkdir build)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR)%.o: %.s
	if not exist build (mkdir build)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR)%.o: $(SOURCES_LIB)
	if not exist build (mkdir build)
	$(CC) $(CFLAGS) -c $< -o $@

decomp:
	$(TOOLCHAIN_PREFIX)objdump firmware.elf -h > sects
	$(TOOLCHAIN_PREFIX)objdump firmware.elf -d --disassemble-all > decomp

clean:
	del *.o
	del *.hex
	del *.elf
	del *.bin
	del decomp
	del sects
	rmdir /s /q build
