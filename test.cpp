#include <stdio.h>

extern "C" void my_printf(const char*, ...);

int main() 
{
    int dec_num = -222;
    int bin_num = 0b111000;
    int hex_num = 0x333000;
    const char* test_str = "777";

    my_printf("Hello world!(%d)(%x)(%b)(%s)%%%%%%", dec_num, hex_num, bin_num, test_str);

    return 0;
}