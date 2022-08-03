SDRAM_START_ADDR = 0x2000000;

ENTRY(main)

SECTIONS
{
	.prog_instr SDRAM_START_ADDR : AT(0)
	{
		* ( .text )
	}

	.prog_data :
	{
		* ( .rodata .data .bss )
	}
	
	.end :
	{
		. = ALIGN(4);
		QUAD(0x1234ABCD)
	}
}
