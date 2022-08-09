int main()
{
	char str[] = "123456789  ABCD";
	volatile unsigned int* gpio_o = (unsigned int*) 0x10000000;
	char *ch;
	
	while (1)
	{
		for (ch = str; *ch != '\0'; ch++)
		{
			*gpio_o = *ch;
			
			for (volatile int i = 0; i < 250000; i++);
				
		}
		
	}
}
