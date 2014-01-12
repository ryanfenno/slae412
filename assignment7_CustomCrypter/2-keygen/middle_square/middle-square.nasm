global _start
section .text
_start:
    xor ecx, ecx
    mul ecx
    xor ebx, ebx
    cdq

   mov cx, 0xffff
seedLoop:
    mov  eax, ecx
    push ecx
    push word 0xff
    pop  cx
midsqLoop:
        mov  ebx, eax
        mul  ebx
        cmp  eax, 0x0
        je   breakLoop
        shl  eax, 8
        shr  eax, 16
        loop midsqLoop
breakLoop:
    pop  ecx
    loop seedLoop


    ; exit
    push 0x1
    pop  eax
    xor  ebx, ebx
    int 0x80
