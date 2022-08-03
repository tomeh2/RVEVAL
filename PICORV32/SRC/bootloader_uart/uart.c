#include "uart.h"

#ifndef __UART_H_
#define __UART_H_

static volatile unsigned int* uart_div_reg = (unsigned int*) 0x3000000;
static volatile unsigned int* uart_wdata_reg = (unsigned int*) 0x3000004;
static volatile unsigned int* uart_rdata_reg = (unsigned int*) 0x3000008;

void uart_init(unsigned int clk_speed, unsigned int baud_rate, unsigned int* uart_dev_base_addr)
{
	uart_div_reg = uart_dev_base_addr;
	uart_wdata_reg = uart_dev_base_addr++;
	uart_rdata_reg = uart_wdata_reg++;

	unsigned int uart_div = clk_speed / baud_rate;
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

char uart_getc()
{
	return (char) *uart_rdata_reg;
}
#endif
