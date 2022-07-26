int main()
{
	volatile unsigned int* sdram = (unsigned int*) 0x2000000;
	volatile unsigned int* gpio_o = (unsigned int*) 0x1000000;
	volatile unsigned int* gpio_i = (unsigned int*) 0x1000004;
	
	*gpio_o = 0xFF;
	for (volatile int j = 0; j < 1000000; j++);
	*gpio_o = 0x00;
	for (volatile int j = 0; j < 1000000; j++);
	*gpio_o = 0xFF;
	for (volatile int j = 0; j < 1000000; j++);
	
	
	for (int i = 0; i < 10; i++)
	{
		*(sdram + i) = 0xF0F0F0F0 + i;
	}
	
	int i = 0;
	while(i < 10)
	{
		for (volatile int j = 0; j < 500000; j++);
		
		*gpio_o = *(sdram + i);
		
		i++;
	}

	return 1;
}
