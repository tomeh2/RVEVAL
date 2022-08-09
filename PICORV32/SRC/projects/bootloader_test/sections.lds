SDRAM_PROG_ADDR = 0x20000000;
BOOTLOADER_ADDR_START = 0x0;

ENTRY(_start)

SECTIONS
{
	rom_bootloader_start = BOOTLOADER_ADDR_START;
	.bootldr 0 : AT(rom_bootloader_start)
	{
		start.o ( .text )
		bootloader.o ( .text )
		uart.o ( .text )
	}
	rom_bootloader_end = rom_bootloader_start + SIZEOF(.bootldr);
	
	.data_bootldr :
	{
		start.o ( .rodata .data .bss )
		bootloader.o ( .rodata .data .bss )
		uart.o ( .rodata .data .sdata )
	}
	rom_rodata_end = rom_bootloader_end + SIZEOF(.data_bootldr);
	
	. = ALIGN(4);
	
	rom_prog_start = .;
	.prog_instr SDRAM_PROG_ADDR : AT(rom_rodata_end)
	{
		program.o ( .text )
		program.o ( .rodata .data .bss )
		
	}
	rom_prog_end = rom_prog_start + SIZEOF(.prog_instr);
}
