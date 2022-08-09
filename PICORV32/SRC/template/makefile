TOOLCHAIN_PREFIX := riscv32-unknown-elf-
PYTHON := python

CFLAGS := -ffreestanding -nostdlib -mabi=ilp32 -march=rv32i
CC := $(TOOLCHAIN_PREFIX)gcc

LIB_DIR := ../lib/

SOURCES_C := $(wildcard *.c)
SOURCES_S := $(wildcard *.s)
SOURCES_LIB := $(wildcard $(LIB_DIR)*.c)
OBJECTS_LIB := $(patsubst ../lib/%.c, %.o, $(SOURCES_LIB))
FIRMWARE_OBJS := $(patsubst %.c, %.o, $(SOURCES_C))
FIRMWARE_OBJS += $(patsubst %.s, %.o, $(SOURCES_S))
FIRMWARE_OBJS += $(OBJECTS_LIB)

$(info $(SOURCES))
$(info $(FIRMWARE_OBJS))
$(info $(LIB_DIR))

.PHONY: hex clean

hex: firmware.bin makehex.py
	$(PYTHON) makehex.py $< 1024 > firmware.hex

firmware.bin: firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

firmware.elf: $(FIRMWARE_OBJS)
	$(CC) -Os -mabi=ilp32 -march=rv32i -ffreestanding -nostdlib -o $@ \
		-Wl,--build-id=none,-Bstatic,-T,sections.lds,--strip-debug \
		$(FIRMWARE_OBJS) -lgcc

%.o: $(LIB_DIR)%.c
	$(CC) $(CFLAGS) -c $<

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(CC) $(CFLAGS) -c $<

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
