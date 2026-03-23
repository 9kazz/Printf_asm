#include <stdio.h>

extern void my_printf(const char*, ...);

int main() 
{
    int dec_num = 111;
    int hex_num = 0x333;
    const char* test_str = "777";

    my_printf("Hello world!(%d)(%x)(%s)%%%%%%", dec_num, hex_num, test_str);

    return 0;
}