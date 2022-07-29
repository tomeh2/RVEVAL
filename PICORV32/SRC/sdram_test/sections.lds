ENTRY(_start)

SECTIONS
{
	.prog 0 : AT(0)
	{
		start.o ( .text )
		prog.o ( .text )
	}
	
	.data :
	{
		*( .rodata )
		*( .data )
		*( .bss )
	}
}
