global _start
section .text
_start:
    ; initialize general registers to zero
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

;=================================

    ; put /etc/passwd on the stack
    ; ----------------------------
    ; open file
    jmp filepath
shellcode:
    mov eax, 0x5
    pop ebx
    xor ecx, ecx
    int 0x80
    mov ebx, eax

    ; read file
    mov eax, 0x3
    mov edi, esp
    mov ecx, edi
    mov edx, 0x1000
    int 0x80
    
    ; test "ro" substring value
    ;mov bx, 0xe2ff
    ;pop ax
    ;ror ax, 0x8
    ;xor ax, bx
    ;push ax

    ; generate key & IV w/ middle square method
    ; -----------------------------------------
    xor ecx, ecx
    mul ecx
    xor ebx, ebx
    cdq

    ; store the "ro" characters in esi
    pop dx
    ror dx, 0x8
    mov esi, edx

    ;mov cx, 0xffff
    ; for testing key gen
    mov cx, 0x3f0a
seedLoop:
    mov  eax, ecx
    push ecx
    push word 0xff
    pop  cx
midsqLoop:
        mov  ebx, eax     ; copy eax to ebx for squaring
        mul  ebx          ; perform square
        cmp  eax, 0x0
        je   breakLoop
        shl  eax, 0x08    ; drop leftmost 8-bits
        shr  eax, 0x10    ; drop rightmost 8-bits
        push eax
        xor  eax, esi
        cmp  eax, 0x9090  ; perform comparison to trigger key/iv gen
        je   keyivgen
        pop  eax
        loop midsqLoop
breakLoop:
    pop  ecx
    loop seedLoop
keyivgen:
    pop  eax        ; restore the match that sent us here...
    mov  ecx, 0xC   ; the next 12 numbers (24 bytes) pushed
                    ; to the stack are the key and IV
midsqLoop2:
    mov  ebx, eax
    mul  ebx
    shl  eax, 0x08
    shr  eax, 0x10
    push ax
    loop midsqLoop2

;=================


endkeygen:

    ; exit
    mov eax, 0x1
    mov ebx, 0x0
    int 0x80

filepath:
    call shellcode
    path: db "/etc/passwd", 0x0
