#include "uart_xilinx.h"

#ifndef __UART_H_
#define __UART_H_

#define CLK_SPEED 100000000
#define BAUD_RATE 19200

static volatile unsigned int* uart_div_reg = (unsigned int*) 0x20000000;
static volatile unsigned int* uart_wdata_reg = (unsigned int*) 0x20000004;
static volatile unsigned int* uart_rdata_reg = (unsigned int*) 0x20000008;

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
