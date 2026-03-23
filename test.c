#include <stdio.h>

extern void my_printf(const char*, ...);

int main() 
{
    int dec_num = -111;
    int bin_num = 0b000111000;
    int hex_num = 0x000333000;
    const char* test_str = "777";

    my_printf("Hello world!(%d)(%x)(%b)(%s)%%%%%%", dec_num, hex_num, bin_num, test_str);

    return 0;
}