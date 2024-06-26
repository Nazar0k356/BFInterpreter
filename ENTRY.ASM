.model tiny

.data
   endCode dw ?
   buff dw 10000 dup(?)
   code_buffer db 10000 dup(?)

.code
org 100h
   start:
   mov di, offset buff
   mov cx, 10000
   rep stosw

    mov cl, byte ptr ds:[80h]
    mov bx, 81h
    add bx, cx
    mov byte ptr ds:[bx], 0

    mov ax, 3d00h ; syscall open file
    mov dx, 82h ; address at which command line is stored 
    int 21h
    mov bx, ax 
 
    mov ah, 3fh ; syscall read file
    mov cx, 10000 ; bytes to read
    lea dx, code_buffer ; to read into code_buffer
    int 21h

    mov di, offset code_buffer
    add ax, di
    mov endCode, ax 

   mov bx, offset buff
   dec di
   
   mainLoop:
   inc di
   cmp di, endCode
   jne cont
   int 20h

   cont:
   mov al, [di] ;Putting symbol of the code into al

   cmp al, 2Bh ;Comparison with +
   jne minus
    inc word ptr [bx]
    jmp mainLoop

   minus:
   cmp al, 2Dh ;Comparison with -
   jne left
    dec word ptr [bx]
    jmp mainLoop

   left:   
   cmp al, 3Ch ;Comparison with <
   jne right
    dec bx
    dec bx
    jmp mainLoop

   right:
   cmp al, 3Eh ;Comparison with >
   jne coma
    inc bx
    inc bx
    jmp mainLoop

   coma: 
   cmp al, 2Ch ;Comparison with ,
   jne dot
    mov ah, 3fh
    mov dx, bx
    push bx
    xor bx, bx
    mov cx, 1
    int 21h

    pop bx
    mov byte ptr [bx+1], 0
    cmp ax, 0
    jne mainLoop

    mov ax, 0ffffh
    mov [bx], ax
    jmp mainLoop

   dot: 
   cmp al, 2Eh ;Comparison with .
   jne lbracket
    mov ah, 02h
    mov dl, [bx]
    ;Checking for enter
    cmp dl, 0dh ;Comparing to cr
    je tomain
    cmp dl, 0ah
    jne output
    mov dl, 0dh
    int 21h
    mov dl, 0ah
    output:
    int 21h
    tomain: jmp mainLoop

   lbracket:   
   cmp al, 5Bh ;Comparison with [
   jne rbracket 
    mov ax, [bx]
    cmp ax, 0
    jne tomain
     mov cx, 1
     findBracket2:
     cmp cx, 0
     je tomain
     inc di
     mov al, [di]
     cmp al, 5Bh ;Comparison with [
     jne case2
     inc cx
     jmp findBracket2
     case2:
     cmp al, 5Dh ;Comparison with ] 
     jne findBracket2
     dec cx
     jmp findBracket2  

   rbracket:
   cmp al, 5Dh ;Comparison with ]  
   jne tomain ;This is a comment
    mov ax, [bx]
    cmp ax, 0
    je tomain
      mov cx, 1
     findBracket1:
     cmp cx, 0
     je tomain
     dec di
     mov al, [di]
     cmp al, 5Bh ;Comparison with [
     jne case1
     dec cx
     jmp findBracket1
     case1:
     cmp al, 5Dh ;Comparison with ] 
     jne findBracket1
     inc cx
     jmp findBracket1
end start