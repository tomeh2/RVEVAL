#define CLK_SPEED 50000000
#define BAUD_RATE 19200
#define SDRAM_SIZE 128

volatile unsigned int* uart_div_reg = (unsigned int*) 0x3000000;
volatile unsigned int* uart_wdata_reg = (unsigned int*) 0x3000004;
volatile unsigned int* uart_rdata_reg = (unsigned int*) 0x3000008;

volatile unsigned int* sdram = (unsigned int*) 0x2000000;
volatile unsigned int* gpio_o = (unsigned int*) 0x1000000;
volatile unsigned int* gpio_i = (unsigned int*) 0x1000004;

char str1[32] = "Initializing SDRAM...\n";
char str2[32] = "Initialization done!\n";
char str3[32] = "Starting check...\n";
char str4[48] = "SDRAM check finished with no errors!\n";

void uart_init()
{
	unsigned int uart_div = CLK_SPEED / BAUD_RATE;
	*uart_div_reg = uart_div;	
}

void uart_putc(char chr)
{
	*uart_wdata_reg = chr;
}

void uart_puts(char* str)
{
	while (*str != '\0')
	{
		uart_putc(*str);
		str++;
	}
}

void sdram_init()
{
	uart_puts(str1);
	for (int i = 0; i < SDRAM_SIZE; i++)
	{
		*(sdram + i) = 0xFFFF0000 + i;
	}
	uart_puts(str2);
}

void sdram_check()
{
	uart_puts(str3);
	for (int i = 0; i < SDRAM_SIZE; i++)
	{
		if (*(sdram + i) != (0xFFFF0000 + i))
		{
			uart_puts("SDRAM Error!\n");
			
			return;
		}
	}
	uart_puts(str4);
}

int main()
{
	uart_init();
	
	/*
	*gpio_o = 0xFF;
	for (volatile int j = 0; j < 1000000; j++);
	*gpio_o = 0x00;
	for (volatile int j = 0; j < 1000000; j++);
	*gpio_o = 0xFF;
	for (volatile int j = 0; j < 1000000; j++);
	*/
	
	//*uart_wdata_reg = 0xFFFFFFFF;
	
	for (int i = 0; i < 10; i++)
	{
		*(sdram + i) = 0xF0F0F0F0 + i;
	}
	
	int i = 0;
	while(i < 10)
	{
		for (volatile int j = 0; j < 100; j++);
		
		sdram_init();
		
		sdram_check();
		/*
		//unsigned int sdram_read_val = 0xF0F0F0F0 + i;
		unsigned int sdram_read_val = *(sdram + i);
		*gpio_o = sdram_read_val;
		*/

		i++;
	}

	return 1;
}
