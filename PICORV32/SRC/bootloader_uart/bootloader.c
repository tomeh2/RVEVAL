#include "uart.h"

#define CLK_SPEED 50000000
#define BAUD_RATE 19200

unsigned int* sdram_base_addr = (unsigned int*) 0x20000000;

unsigned int fetch_instruction()
{
	unsigned int fetched_instr = 0;
	for (int i = 0; i < 4; i++)
	{
		char recv_char = -1;
		do
		{
			recv_char = uart_getc();
		} while (recv_char == -1);
		fetched_instr |= ((unsigned int) recv_char) << 24;
		fetched_instr >>= 8;
	}
	uart_putc((char) fetched_instr);
	uart_putc((char) fetched_instr >> 8);
	uart_putc((char) fetched_instr >> 16);
	uart_putc((char) fetched_instr >> 24);
	return fetched_instr;
}

int bootloader_main()
{
	uart_init(CLK_SPEED, BAUD_RATE, (unsigned int*) 0x30000000);
	
	uart_puts("===================\r\n");
	uart_puts("PICORV32 Bootloader\r\n");
	uart_puts("===================\r\n");
	
	// Wait for start sequence
	
	unsigned int* sdram_curr_addr = sdram_base_addr;
	while (1)
	{
		unsigned int fetched_instr = fetch_instruction();
		
		if (fetched_instr == 0x1234abcd)
			break;
		
		*sdram_curr_addr = fetched_instr;
		sdram_curr_addr++;
	}
	uart_puts("Done!\r\n");
	
	asm("li a0, 0x20000000");
	asm("jalr zero, a0");
	
	return -1;
}

















