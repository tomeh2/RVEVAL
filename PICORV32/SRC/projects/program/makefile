TOOLCHAIN_PREFIX := riscv32-unknown-elf-
PYTHON := python

CC := $(TOOLCHAIN_PREFIX)gcc
CFLAGS := -ffreestanding -nostdlib -march=rv32i -c

FIRMWARE_OBJS := program.o

firmware.hex: firmware.bin makehex.py
	$(PYTHON) makehex.py $< 1024 > $@

firmware.bin: firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

firmware.elf: $(FIRMWARE_OBJS) $(TEST_OBJS) sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -mabi=ilp32 -march=rv32i -ffreestanding -nostdlib -o $@ \
		-Wl,--build-id=none,-Bstatic,-T,sections.lds,--strip-debug \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc

decomp:
	$(TOOLCHAIN_PREFIX)objdump firmware.elf -h > sects
	$(TOOLCHAIN_PREFIX)objdump firmware.elf -d --disassemble-all > decomp
	
clear:
	rm -f *.o
	rm -f *.hex
	rm -f *.elf
	rm -f *.bin
