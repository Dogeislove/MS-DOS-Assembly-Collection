; Turbo Assembler example. Copyright (c) 1993 By Borland International, Inc.

; From the Turbo Assembler User's Guide - Getting started

.MODEL  SMALL
.STACK  100h
.DATA

TimePrompt              DB 'Is it after 12 noon (Y/N)?$'
Hi_Sec                  DW 0
Lo_Sec                  DW 0
;DATA_READ               DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DATA_READ               DB 0220h dup(00h)
.CODE
start:
  ;BASIC SANITY HELLO WORLD FOR NO REASON
  mov     ax,@data            
  mov     ds,ax                   ;set DS to point to the data segment
  mov     es,ax
  mov     dx,OFFSET TimePrompt    ;point to the time prompt
  mov     ah,9                    ;DOS: print string
  int     21h                     ;display the time prompt
  
  ;Scan for Floppy Disk
  ;
  ;DL = DRIVE NUMBER
  ;AH = DEVICE TYPE

  xor     dx, dx ;set dx to zero as we iterate over each device

scan:
  push    dx  ;save the actual value for dx, as dx gets modified after calling
  mov     ah, 15h ;interupt index thing
  int     13h
  
  ;Check for valid drive
  ;01 = actual floppy drive
  ;02 = USB floppy drive

  cmp     ah, 01h
  je      scan_done ;Jump if Equal 
  cmp     ah, 02h
  je      scan_done

  pop     dx ; Restores dx to its original value
  inc     dl ;search next drive
  
  jmp     scan

scan_done:
  ;Save the number of Sectors found by the function, then restore
  ;the value of dx (which contains our drive number)
  mov     [word ptr Hi_Sec], cx  ;store cd into Hi_Sec
  mov     [word ptr Lo_Sec], dx  ;store dx into Lo_Sec
  pop     dx ;Now restore the actual value

scan_disk:  ;Read Disk code
;    mov ah, 08h      
;    int 13h

;    Search Floppy Drive. I am not sure how this works, but here I'll
;    start the search by setting the cylinder and sector to the earliest
;    possible value I can be allowed to set.

    xor cx, cx ;CH = cylinder num, CL = sector num
    xor dh, dh ;head number

   
    mov bx, offset DATA_READ ;es:DATA_READ stores where we want to store the data
    mov al, 01h ;We're going to read the first sector. Note it must start
    ;with one, instead of zero, for some reason   
;    mov ah, 02h
     
read_disk:
    mov ah, 02h
    int 13h
    inc cl
    cmp cl, 64h
    je next_cyl

    ;We shall print. No?
    push cx

    mov cx, 0210h
    mov bp, bx

print_data:
    push cx
    mov cx, 1
    mov al, [byte ptr bp]
    mov ah, 09h 
    int 10h
    pop cx
    inc bp
    loop print_data

    pop cx 

    mov al, 01h
    jmp read_disk
next_cyl:
    mov cl, 01h
    inc ch
    jmp read_disk                  
exit:  
  mov     ah,4ch                  ;DOS: terminate program
  mov     al,0                    ;return code will be 0
  int     21h                     ;terminate the program

END start
