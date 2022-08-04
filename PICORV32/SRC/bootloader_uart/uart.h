void uart_init(unsigned int clk_speed, unsigned int baud_rate, unsigned int* uart_dev_base_addr);
void uart_putc(char chr);
void uart_puts(char* str);
unsigned int uart_getc();
