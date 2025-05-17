;List of PRINT REGISTER utilities I made

.MODEL  SMALL

.STACK  0f12h
.DATA

;                     Size of buffer  Size of input       Data
read              DB       20h,            00h,        8h dup (0)


.CODE

start:
   ;Sets the DATA SEGMENT and EXTRA SEGMENT to the DATA segment through AX
   mov ax, @data 

   mov ds, ax
   mov es, ax

   ;The Buffer where the input is going to
   mov dx, offset read
   ;The number for the "read input to buffer" or whatever
   mov ah, 0ah

   int 21h

   ;Read input buffer

   ;This turns DI -> end of the data just read
   mov di, dx  ;set di to the read buffer
   mov bl, [byte ptr di+1] ;Now add by the size of the input

   add di, bx ;Adds the size of the input
   inc di ;Includes the 2nd byte of the data structure we don't want
   
   ;Set CX to the size of the buffer that was recorded
   mov cx, di
   sub cx, offset read+1 ;Get total number of iterations

   ;Calls a function to turn the user input (in ASCII) to actual hexadecimal
   call interpret_ascii
   ;prints hexadecimal value from ax onto screen
   call hprint

 
  mov     ah,4ch                  ;DOS: terminate program
  mov     al,0                    ;return code will be 0
  int     21h                     ;terminate the program

  ;DI = end of string (expected)
  ;CX = size of string
  ;Result -> di pointing either the next string, or nothing.
  ;cx -> 0
  ;ax -> ASCII value

   ;What we need to do:

   ;convert ASCII to digit
   ;scale the digit based on location to ensure accurate results
   ;stop scaling once we found out we've reached the end

   ;We can stop scaling by realizing we're essentially "iterating"
   ;over each byte, which has a fixed sized. We can take the size of the
   ;buffer vs the 2nd byte (which is not part of the buffer), thus
   ;the number of iterations are buffer-2

   ;thus the code becomes:
   ;mov cx, di
   ;sub cx, offset read+1
   ;solving that problem

   ;Converting to ASCII is simple enough:
   ;subtract by 30h
   ;if greater than 9:
   ;and 1f
   ;subtract by 11
   ;= lower digit

   ;Now converting the digit is trickier because we have to handle where
   ;the ASCII hex ends ('0x20')
   ;We can do this
   ;b = 0x1
   ;while (a != ' ')
   ;   a = read_byte();  -> ax
   ;   a = convert_ascii(a);  -> ax
   ;   c = a * b; -> ax
   ;   d += c     -> dx
   ;   b = b >> 4 -> bx

   ;I rarely multiply, so I don't know how to use it as well.
   ;From a small experiment, I think it works like this:
   ;mul r/m16 ->   ax = r/m16 * ax

   
   ;ax = a -> ax * b = a * b
   ;bx = b -> a * bx = a * b
   ;together: ax * bx = c = ax (after the operation is complete)
   ;dx += ax -> d + c
   ;bx = bx >> 4 which does this

  interpret_ascii: ;Converts representation
           ;Also another possibility for an Error. If greater than 4 bytes
           ;for cx, which is greater than what a 16 bit register can hold
           ;Just once again to show I am aware of the problem, here is
           ;a code that essentially does nothing other than say I'm aware
           cmp cx, 04h
           ;once again I can either make it set up a flag that can be handled
           ;or jump to an existing error handler. The first case is probably
           ;better for a function like this

           ;but here is a dummy jump to show how you could handle it
           ;jg error_handler2
           push bx
           push dx

           mov bx, 01h ;base selected
           xor dx, dx  ;where hexadecimal value being read is going to.
           ;Once it is finished being read, we put in in AX

     convert_rep:
           mov al, [di] ;Moves the byte we're gonna read
           xor ah, ah ;Discards any higher bytes that we don't want
           call convert_ascii ; ax = convert_ascii(a)
          ;Now turn it to proper base
          ;b = 16^i, where i is the number of iterations taken
          push dx ;Didn't realize dx gets modified when mul is finished. Fixed
             mul bx       ;       ax = a * b
          pop dx

          add dx, ax   ;       dx = d + c
          shl bx, 4    ;       bx = b >> 4  or bx *= 0x10
          dec di
          
          loop convert_rep
          xchg ax, dx ;Swaps the dx and ax values, as we intend ax to hold them
         pop dx
        pop bx
       ret
   ;subtract by 30h
   ;if greater than 9:
   ;and 1f
   ;subtract by 11
   ;= lower digit

convert_ascii:
        sub ax, '0' ;Base digit we're subtracting from
        cmp ax, 9 ;If it's greater than 9, that means its hexadecimal,
        ;and we need to adjust the value to get the actual representation.
        ;as ascii of 'f' subtracted by 30 does NOT equal 0x0f, unlike
        ;with numbers

        jng exit_conv
        ;NOTE: lowercase ascii values are I think like 0x30 more?
        ;So to basically discard those bits we don't want, we use a mask
        ;so it equals the same as the uppercase representation
        and ax, 01fh ;fix ASCII representation by turning it to lowercase_ascii - 0x30
        
        sub ax, 7h  ;and.. It should be the proper representation now

        ;code that can one day implement an error. But for now, it'll just
        ;be here to show that I have thought about the possibility
        ;of the wrong input being entered
        cmp al, 0fh

        ;if it was greater than 0fh (like because of say 47, which would be
        ;0x10 which is not a digit but a number, then we'd maybe either
        ;set a flag or jump to an error message. Setting a flag is far more
        ;general than a jump, as I'd have to copy it, and what if the user
        ;wanted to handle it? But here, I'll use a jump for simplicity

        ;jg error_handler

exit_conv:
        ret

                    
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
