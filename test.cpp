#include <stdio.h>

extern "C" void my_printf(const char*, ...);

int main() 
{
    int zero    = 0;
    int bin_num = 0b111000;
    int dec_num = -222;
    int oct_num = 0333;
    int hex_num = 0xABC123;
    char character = '$';
    const char* test_str = "STR";
    double dub_num1 = -0.009;
    double dub_num2 = -0.009;


    printf("====================================================================\n");
    printf("1 message from MY_PRINTF | 2 message from STD PRINTF:\n\n");
    
    my_printf("HELLO WORLD!\n(%b) (%b) (%d) (%o) (%x) (%c) (%s) \"%%%%%%%%%%\" (%f) (%.2f)\n\n", zero, bin_num, dec_num, oct_num, hex_num, character, test_str, dub_num1, dub_num2);

    printf("====================================================================\n");

    return 0;
}