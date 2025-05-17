;UNFINISHED
.MODEL  SMALL
.STACK  100h
.DATA

File             DB 'editor.asm'
Text_Read               DB  5000h                  dup(0)
.CODE
start:
  mov     ax,@data

  mov     ds,ax                   ;set DS to point to the data segment
  mov dx, offset File

  mov al, 02h
  mov ah, 3dh

  int 21h

  xchg ax, bx

  mov cx, 100
  mov ah, 3fh
  int 21h


  ;Run Loop
file_loop:
   mov ah, 10h
   int 16h

   cmp ah, 50h
   je down_arrow

   cmp ah, 48h
   je up_arrow

   cmp ah, 4bh
   je left_arrow

   cmp ah, 4dh
   je right_arrow

   cmp al, 'a'
   jne file_loop
quit_loop:
  ;close file
  mov ah, 3Eh
  int 21h

  mov     ah,4ch                  ;DOS: terminate program
  mov     al,0                    ;return code will be 0
  int     21h                     ;terminate the program
left_arrow:
        ;GET CURSOR POSITION
        mov ah, 03h
        mov bh, 00h
        int 10h
        mov ah, 02h
        mov bh, 00h
        dec dl
        int 10h
        jmp file_loop
right_arrow:
        ;GET CURSOR POSITION
        mov ah, 03h
        mov bh, 00h
        int 10h
        mov ah, 02h
        mov bh, 00h
        inc dl
        int 10h
        jmp file_loop

down_arrow:
        ;GET CURSOR POSITION
        mov ah, 03h
        mov bh, 00h
        int 10h
        mov ah, 02h
        mov bh, 00h
        inc dh
        int 10h

        mov ah, 01h
        int 10h



        jmp file_loop
up_arrow:
        ;GET CURSOR POSITION
        mov ah, 03h
        mov bh, 00h
        int 10h
        mov ah, 02h
        mov bh, 00h
        dec dh
        int 10h

        mov ah, 01h
        int 10h
        jmp file_loop
        


END start
