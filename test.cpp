#include <stdio.h>

extern "C" void my_printf(const char*, ...);

int main() 
{
    int zero    = 0;
    int bin_num = 0b111000;
    int dec_num = -222;
    int oct_num = 0333;
    int hex_num = 0xABC123;
    const char* test_str = "STR";
    double dub_num = 1.9;

    printf("====================================================================\n");
    printf("1 message from MY_PRINTF | 2 message from STD PRINTF:\n\n");
    
    // printf("%.2f\n", dub_num);
    // my_printf("HELLO WORLD!\n(%b) (%b) (%d) (%o) (%x) (%s) (%%%%%%%%%%) (%f)\n\n", zero, bin_num, dec_num, oct_num, hex_num, test_str, dub_num);
my_printf("%.3f\n", dub_num);
    printf("====================================================================\n");

    return 0;
}