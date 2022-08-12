#include "uart.h"

#ifndef __UART_H_
#define __UART_H_

#define CLK_SPEED 50000000
#define BAUD_RATE 19200

static volatile unsigned int* uart_div_reg = (unsigned int*) 0x30000000;
static volatile unsigned int* uart_wdata_reg = (unsigned int*) 0x30000004;
static volatile unsigned int* uart_rdata_reg = (unsigned int*) 0x30000008;

char hexMap[16] = "0123456789ABCDEF";

void format_hex(unsigned int num, char* dest)
{
	for (int i = 0; i < 8; i++)
	{
		*(dest + 7 - i) = *(hexMap + (num & 0x0000000F));
		num >>= 4;
	}
}

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
#endif
