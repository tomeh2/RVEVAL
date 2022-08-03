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
		bootloader.o ( .rodata .data .bss )
		uart.o ( .rodata .data .bss )
	}
	rom_rodata_end = rom_bootloader_end + SIZEOF(.data_bootldr);
}
