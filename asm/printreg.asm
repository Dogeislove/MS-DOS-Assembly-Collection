;List of PRINT REGISTER utilities I made

.MODEL  SMALL

;.STACK  100h
.DATA

.CODE
;.org 7c00h

start:
   mov cx, 100h
   call print_memory
;  mov     bx, 0ffffh
;  call    hprint  
 
  mov     ah,4ch                  ;DOS: terminate program
  mov     al,0                    ;return code will be 0
  int     21h                     ;terminate the program


bprint:    ;Print ax in binary
;Uses "fake" arguement ax. bx is "true" argument, though swapped
          push bx
          push cx
          mov bx, ax
          mov cx, 10h ;Loop 16 bits (max size of register)
          mov ah, 0eh ;Teletype Output
loop_print: ;Reads the MSB
          xor al, al ;Ensure there is no overwrite from previous instruction
          rol bx, 1h ;Rotates to the left. Sets Carry Flag if MSB = 1          
          adc al, 30h ;If carry flag was set (when MSB equals 1) add by one
          int 10h
          loop loop_print
          mov ax, bx
          pop cx
          pop bx
          ret


bprintc:  ;Print al in binary
        push bx
        push cx
        mov bx, ax
        mov cx, 8h
        mov ah, 0eh
bprintlo:
        xor al, al
        rol bl, 1
        adc al, 30h
        int 10h
        loop bprintlo
        mov ax, bx
        pop cx
        pop bx
        ret

hprint: ;prints ax in hexadecimal
      push bx
      push cx
      
      mov bx, ax ;Lazy fix so that AX = print char
      mov cx, 4h
      mov ah, 0eh
;Loop to print Hexadecimal digit      
hprintlo:
      rol bx, 4 ;rotates the four bits
      mov al, bl
      and al, 0fh
      add al, 30h

      cmp al, 39h ;If it is greater than 0x39, we must adjust it to be accurate
      jng hprint_fin
hprint_adjust: ;adjust the hexadecimal value to display onscreen     
      sub al, 0ah ;Get to DECIMAL 
      add al, 11h ;Now it should be 0x41 -> 'a'
hprint_fin:  ;Finish one iteration
      int 10h
      loop hprintlo
      mov ax, bx ;Restores ax again to its default value
      pop cx
      pop bx
      ret

hprintb: ;prints al in hex
      push bx
      push cx
      mov bx, ax ;Lazy fix
      mov cx, 2h
      mov ah, 0eh
;Loop to print Hexadecimal digit      
hprintblo:
      rol bl, 4 ;rotates the four bits
      mov al, bl
      and al, 0fh
      add al, 30h

      cmp al, 39h ;If it is greater than 0x39, we must adjust it to be accurate
      jng hprintb_fin
hprintb_adjust: ;adjust the hexadecimal value to display onscreen     
      sub al, 0ah ;Get to DECIMAL 
      add al, 11h ;Now it should be 0x41 -> 'a'
hprintb_fin:  ;Finish one iteration
      int 10h
      loop hprintblo
      mov ax, bx
      pop cx
      pop bx
      ret

print_memory: ;Prints Memory Section ds:si by cx times
     push ax
     push di
     mov ah, 0eh
mem_loop:
     lodsb
     call hprintb
     ;add space
     mov al, 20h
     int 10h
     loop mem_loop
     pop di
     pop ax
     ret
      

END start
