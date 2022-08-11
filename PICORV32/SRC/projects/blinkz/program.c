int main()
{
	volatile unsigned int* gpio_o = (unsigned int*) 0x40000000;

	while (1)
	{
		for (volatile int i = 0; i < 200000; i++);
		*gpio_o = 0xFF;
		for (volatile int i = 0; i < 200000; i++);
		*gpio_o = 0x00;
	}

	return 0;
}
