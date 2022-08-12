#include "uart.h"

unsigned int* bram_start_addr = (unsigned int*) 0x10000000;
const unsigned int BRAM_SIZE_WORDS = 512;

unsigned int* sdram_start_addr = (unsigned int*) 0x20001000;
const unsigned int SDRAM_SIZE_WORDS = 131072;		//We are not testing the whole SDRAM

unsigned int* gpio_o = (unsigned int*) 0x30000004;

int test_bram()
{
	unsigned int* bram_curr_addr = bram_start_addr;
	uart_puts("Writing to BRAM...\r\n");
	for (int i = 0; i < BRAM_SIZE_WORDS; i++)
	{
		*bram_curr_addr = 0xF0F0FF00 + i;
		bram_curr_addr++;
	}
	uart_puts("Done!\r\n");
	
	bram_curr_addr = bram_start_addr;
	uart_puts("Reading from BRAM...\r\n");
	for (int i = 0; i < BRAM_SIZE_WORDS; i++)
	{
		if (*bram_curr_addr != 0xF0F0FF00 + i)
		{
			char hexStr[9];
			hexStr[8] = '\0';
			
			format_hex(0xF0F0FF00 + i, hexStr);
			uart_puts("Expected: ");
			uart_puts(hexStr);
			
			format_hex(*bram_curr_addr, hexStr);
			uart_puts(" | Got: ");
			uart_puts(hexStr);
			uart_puts("\r\n");
		
			return -1;
		}
		bram_curr_addr++;
	}
	uart_puts("BRAM check finished without errors!\r\n");
	return 0;
}

int test_sdram()
{
	unsigned int* sdram_curr_addr = sdram_start_addr;
	uart_puts("Writing to SDRAM...\r\n");
	for (int i = 0; i < SDRAM_SIZE_WORDS; i++)
	{		
		*sdram_curr_addr = 0xF0F0FF00 + i;
		sdram_curr_addr++;
	}
	uart_puts("Done!\r\n");
	
	sdram_curr_addr = sdram_start_addr;
	uart_puts("Reading from SDRAM...\r\n");
	for (int i = 0; i < SDRAM_SIZE_WORDS; i++)
	{
		if (*sdram_curr_addr != 0xF0F0FF00 + i)
		{
			char hexStr[9];
			hexStr[8] = '\0';
			
			format_hex(0xF0F0FF00 + i, hexStr);
			uart_puts("Expected: ");
			uart_puts(hexStr);
			
			format_hex(*sdram_curr_addr, hexStr);
			uart_puts(" | Got: ");
			uart_puts(hexStr);
			uart_puts("\r\n");
		
			return -1;
		}
		sdram_curr_addr++;
	}
	uart_puts("SDRAM check finished without errors!\r\n");
	return 0;
}

int main()
{
	if (test_bram() == -1)
		uart_puts("BRAM ERROR!\r\n");
	
	if (test_sdram() == -1)
		uart_puts("SDRAM ERROR!\r\n");

	uart_puts("All tests doneee!\r\n");

	return 0;
}
