#include <neorv32.h>
#include <neorv32_uart.h>

volatile unsigned int* sdram_addr = (unsigned int*) 0x40000000;

int main() {

	neorv32_gpio_port_set(0);

	int cnt = 0;

	neorv32_uart0_print("SDRAM Test Software v0.1\n");
	
	neorv32_uart0_print("Writing to RAM...\n");
	for (int i = 0; i < 256; i++)
	{
		*(sdram_addr + i) = 0xFFFF0000 + i;
	}
	neorv32_uart0_print("Done!\n");
	
	neorv32_uart0_print("Reading from RAM...\n");
	for (int i = 0; i < 256; i++)
	{
		neorv32_uart0_printf("%x = %u\n", sdram_addr + i, *(sdram_addr + i));
	}
	neorv32_uart0_print("Done!\n");
}
