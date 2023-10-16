#include <stdint.h>

#define UART_BASE 0x10000000

#define UART_RBR UART_BASE + 0
#define UART_THR UART_BASE + 0
#define UART_INTERRUPT_ENABLE UART_BASE + 4
#define UART_INTERRUPT_IDENT UART_BASE + 8
#define UART_FIFO_CONTROL UART_BASE + 8
#define UART_LINE_CONTROL UART_BASE + 12
#define UART_MODEM_CONTROL UART_BASE + 16
#define UART_LINE_STATUS UART_BASE + 20
#define UART_MODEM_STATUS UART_BASE + 24
#define UART_DLAB_LSB UART_BASE + 0
#define UART_DLAB_MSB UART_BASE + 4

void write_reg_u8(uintptr_t addr, uint8_t value)
{
    volatile uint8_t *loc_addr = (volatile uint8_t *)addr;
    *loc_addr = value;
}

uint8_t read_reg_u8(uintptr_t addr)
{
    return *(volatile uint8_t *)addr;
}

int is_transmit_empty()
{
    return read_reg_u8(UART_LINE_STATUS) & 0x20;
}

void write_serial(char a)
{
    while (is_transmit_empty() == 0) {};

    write_reg_u8(UART_THR, a);
}

void init_uart(uint32_t freq, uint32_t baud)
{
    uint32_t divisor = freq / (baud << 4);

    write_reg_u8(UART_INTERRUPT_ENABLE, 0x00); // Disable all interrupts
    write_reg_u8(UART_LINE_CONTROL, 0x80);     // Enable DLAB (set baud rate divisor)
    write_reg_u8(UART_DLAB_LSB, divisor);         // divisor (lo byte)
    write_reg_u8(UART_DLAB_MSB, (divisor >> 8) & 0xFF);  // divisor (hi byte)
    write_reg_u8(UART_LINE_CONTROL, 0x03);     // 8 bits, no parity, one stop bit
    write_reg_u8(UART_FIFO_CONTROL, 0xC7);     // Enable FIFO, clear them, with 14-byte threshold
    write_reg_u8(UART_MODEM_CONTROL, 0x20);    // Autoflow mode
}

void print_uart(const char *str)
{
    const char *cur = &str[0];
    while (*cur != '\0')
    {
        write_reg_u8(UART_THR, *cur);
	++cur;
    }
}

uint8_t bin_to_hex_table[16] = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

void bin_to_hex(uint8_t inp, uint8_t res[2])
{
    res[1] = bin_to_hex_table[inp & 0xf];
    res[0] = bin_to_hex_table[(inp >> 4) & 0xf];
    return;
}

void print_uart_int(uint32_t addr)
{
    int i;
    for (i = 3; i > -1; i--)
    {
        uint8_t cur = (addr >> (i * 8)) & 0xff;
        uint8_t hex[2];
        bin_to_hex(cur, hex);
        write_serial(hex[0]);
        write_serial(hex[1]);
    }
}

void print_uart_addr(uint64_t addr)
{
    int i;
    for (i = 7; i > -1; i--)
    {
        uint8_t cur = (addr >> (i * 8)) & 0xff;
        uint8_t hex[2];
        bin_to_hex(cur, hex);
        write_serial(hex[0]);
        write_serial(hex[1]);
    }
}

void print_uart_byte(uint8_t byte)
{
    uint8_t hex[2];
    bin_to_hex(byte, hex);
    write_serial(hex[0]);
    write_serial(hex[1]);
}

void print_string_to_uart(const char* str) {
	int i=0;
    while (str[i] != '\n') {
        write_reg_u8(UART_THR, str[i]);
        i++;
    }
}

int main()
{
    init_uart(50000000, 115200);

char message = 'H';
write_serial(message);
 message = 'E';
write_serial(message);
 message = 'L';
write_serial(message);
 message = 'L';
write_serial(message);
 message = 'O';
write_serial(message);
 message = ' ';
write_serial(message);
 message = 'F';
write_serial(message);
 message = 'A';
write_serial(message);
 message = 'B';
write_serial(message);
 message = 'I';
write_serial(message);
 message = 'E';
write_serial(message);
 message = 'N';
write_serial(message);



    //long int b=5;
 // print_uart_addr(b);
//print_string_to_uart(message);

    while (1)
    {
        // do nothing
    }
}

void handle_trap(void)
{
     print_uart("trap\r\n");
}
