SDRAM_PROG_ADDR = 0x20000000;
BOOTLOADER_ADDR_START = 0x0;

ENTRY(_start)

SECTIONS
{
	rom_bootloader_start = BOOTLOADER_ADDR_START;
	.bootldr 0 : AT(rom_bootloader_start)
	{
		build/start.o ( .text )
		build/bootloader.o ( .text )
		build/uart.o ( .text )
	}
	rom_bootloader_end = rom_bootloader_start + SIZEOF(.bootldr);
	
	.data_bootldr :
	{
		build/start.o ( .rodata .data .bss )
		build/bootloader.o ( .rodata .data .bss )
		build/uart.o ( .rodata .data .sdata )
	}
	rom_rodata_end = rom_bootloader_end + SIZEOF(.data_bootldr);
	
	. = ALIGN(4);
	
	rom_prog_start = .;
	.prog_instr SDRAM_PROG_ADDR : AT(rom_prog_start)
	{
		build/program.o ( .text )
		build/program.o ( .rodata .data .bss )
		
	}
	rom_prog_end = rom_prog_start + SIZEOF(.prog_instr);
}
