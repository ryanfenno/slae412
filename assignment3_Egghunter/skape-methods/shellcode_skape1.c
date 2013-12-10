/*
based on skape's first access(2) method
http://www.hick.org/code/skape/papers/egghunt-shellcode.pdf
*/

#include <stdio.h>
#include <string.h>

#define MARKER    "\x93\x51\x93\x59"
/*
     93       xchg   ebx,eax
     51       push   ecx
     93       xchg   ebx,eax
     59       pop    ecx
     (as far as assembly goes, this is pretty preposterous)
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
"\xbb"    MARKER    "\x31\xc9\xf7\xe1\x66\x81\xca\xff\x0f\x42"
"\x60\x8d\x5a\x04\xb0\x21\xcd\x80\x3c\xf2\x61\x74\xed\x39\x1a"
"\x75\xee\x39\x5a\x04\x75\xe9\xff\xe2";
/*
    global _start
    section .text
    _start:
        mov ebx, 0x59935193    ; marker
        xor ecx, ecx           ; clear eax, ecx, edx
        mul ecx
    fillOnes:
        or dx, 0xfff
    shiftUp:
        inc edx
        pusha
        lea ebx, [edx+0x4]
        mov al, 0x21           ; access(2)
        int 0x80
        cmp al, 0xf2           ; compare against low byte of EFAULT return value
        popa
        jz fillOnes            ; increase edx by PAGE_SIZE (0x1000, 4096, 4MB)
                               ; and try again if EFAULT was returned
        cmp [edx], ebx
        jnz shiftUp
        cmp [edx+0x4], ebx
        jnz shiftUp
        jmp edx                ; MARKER must be valid assembly
*/

void main() {
    printf("egghunter length: %d\n", strlen(egghunter));
    printf("shellcode length: %d\n", strlen(shellcode));
    ((int(*)())egghunter)();
}


