#include <neorv32.h>
#include <neorv32_uart.h>

#define SDRAM_TEST_SIZE 65536

volatile unsigned int* sdram_addr = (unsigned int*) 0x40000000;

int main() {

	neorv32_gpio_port_set(0);

	neorv32_uart0_print("SDRAM Test Software v0.1\n");
	
	neorv32_uart0_print("Writing to RAM...\n");
	for (int i = 0; i < SDRAM_TEST_SIZE; i++)
	{
		if (i % 1000 == 0)
		{
			neorv32_uart0_printf("%d of %d\n", i, SDRAM_TEST_SIZE);
		}
		
		*(sdram_addr + i) = 0xFFFF0000 + i;
	}
	neorv32_uart0_print("Done!\n");
	
	neorv32_uart0_print("Reading from RAM...\n");
	for (int i = 0; i < SDRAM_TEST_SIZE; i++)
	{
		if (i % 1000 == 0)
		{
			neorv32_uart0_printf("%d of %d\n", i, SDRAM_TEST_SIZE);
		}
		
		unsigned int sdram_read_val = *(sdram_addr + i);
		if (sdram_read_val != 0xFFFF0000 + i)
		{
			neorv32_uart0_printf("Error at %x! Expected: %x | Got: %x\n", sdram_addr + i, 0xFFFF0000 + i, sdram_read_val);
			return -1;
		}
	}
	neorv32_uart0_print("Done!\n");
	
	return 0;
	
}
