int main()
{
	volatile unsigned int* gpio_o = (unsigned int*) 0x1000000;
	
	while (1)
	{
		for (volatile int i = 0; i < 500000; i++);
		*gpio_o = 0xFF;
		
		for (volatile int i = 0; i < 500000; i++);
		*gpio_o = 0x00;
	}
}
