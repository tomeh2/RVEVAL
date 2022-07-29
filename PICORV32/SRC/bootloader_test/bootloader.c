#include "uart.h"

extern int main();

extern char rom_prog_start;
extern char rom_prog_end;

char hexMap[16] = "0123456789ABCDEF";

void format_hex(unsigned int num, char* dest)
{
	for (int i = 0; i < 8; i++)
	{
		*(dest + 7 - i) = *(hexMap + (num & 0x0000000F));
		num >>= 4;
	}
}

int bootloader_entry()
{
	uart_init();
	
	uart_puts("Bootloader started!\n");

	unsigned int* prog_curr_addr = (unsigned int*) &rom_prog_start;
	unsigned int* sdram_curr_addr = (unsigned int*) 0x2000000;

	char hexVal[9];
	hexVal[8] = '\0';
	format_hex((unsigned int) prog_curr_addr, hexVal);
	uart_puts("Program start address: ");
	uart_puts(hexVal);
	uart_putc('\n');
	
	format_hex((unsigned int) &rom_prog_end, hexVal);
	uart_puts("Program end address: ");
	uart_puts(hexVal);
	uart_putc('\n');

	uart_puts("Loading...\n");
	while (prog_curr_addr < (unsigned int*) &rom_prog_end)
	{
		*sdram_curr_addr = *prog_curr_addr;
		sdram_curr_addr++;
		prog_curr_addr++;
	}
	uart_puts("Done! Starting program\n");

	main();
}
