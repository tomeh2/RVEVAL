TOOLCHAIN_PREFIX := riscv32-unknown-elf-
PYTHON := python3

FIRMWARE_OBJS := start.o program.o bootloader.o uart.o

firmware.hex: firmware.bin makehex.py
	$(PYTHON) makehex.py $< 1024 > $@

firmware.bin: firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

firmware.elf: $(FIRMWARE_OBJS) $(TEST_OBJS) sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -mabi=ilp32 -march=rv32i -ffreestanding -nostdlib -o $@ \
		-Wl,--build-id=none,-Bstatic,-T,sections.lds,--strip-debug \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc
	chmod -x $@
	
start.o:
	$(TOOLCHAIN_PREFIX)gcc -c start.s -ffreestanding -nostdlib -march=rv32i 
	
program.o:
	$(TOOLCHAIN_PREFIX)gcc -c program.c -ffreestanding -nostdlib -march=rv32i 
	
bootloader.o:
	$(TOOLCHAIN_PREFIX)gcc -c bootloader.c -ffreestanding -nostdlib -march=rv32i 
	
uart.o: uart.c uart.h
	$(TOOLCHAIN_PREFIX)gcc -c uart.c -ffreestanding -nostdlib -march=rv32i 
	
decomp:
	$(TOOLCHAIN_PREFIX)objdump firmware.elf -h > sects
	$(TOOLCHAIN_PREFIX)objdump firmware.elf -d --disassemble-all > decomp
	
clear:
	rm -f *.o
	rm -f *.hex
	rm -f *.elf
	rm -f *.bin
