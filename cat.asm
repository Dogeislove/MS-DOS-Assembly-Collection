;Cat Program
;Outputs text to screen
;This is the new version
;The last one was 400 lines, and this does the same thing
;but is 140 lines when stripped of comments, constants, and tabs
;It's even shorter if I could simplify it
;I didn't test it, but I think its like 130ish lines

ideal  ;Ideal mode, it is a task thing,  idrk it very well
group DGROUP _DATA, _TEXT ;This lets us group the text (our code) with data
;the reason we use this kind of stuff is because tasm doesn't by default
;put the variables where they should be, which is annoying

segment _TEXT byte 'CODE' ;I have no idea what this means or even does
        org 100h ;All I know is we define the code segment to be _TEXT
ends

segment _DATA byte 'DATA'
ends

segment _DATA
        Assume DS:_DATA ;The data must be told to assume we're actually at DS:_DATA, rather than anything else. I hate memory segments
        ;This is where we put filenames
        buffer dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ;buffer size
        buf_sz dw $-buffer
        Buf_Write dw ?
        Next_File dw ? ;The next File we're reading
        ;Buffer isn't I think ever used as an actual buffer, we actually just read one byte at a time
        byte_buf db 0 ;for readin
        
        file_head dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0        
        ;some stuff
        ;this is the end of the actual data right now
        drive_end dw ?
        is_drive db 0

ends

segment _TEXT
        org 100h ;Starts at 100h
        Assume CS:_Text 
        Assume DS:_DATA
        
        ;Defines constants
        ;Assembly uses a lot, and sometimes, they get confusing.
        ;So I name them roughly of what they actually do
        PSP_Arg = 82h

        PSP_Size = 80h
        PSP_Overflow = 7Eh
        Delimit = 0Dh  ;This character is where we stop reading, and then move on
        ;HANDLERS
        ;These are handlers (I believe), that tell assembly what (from the interrupt we chose) to execute
        Print_Func = 9h
        Open_File = 3Dh

	start:
                mov bp, PSP_Size

                mov al, [bp] ;Size of the arg

                cmp al, PSP_Overflow ;PSP_Overflow is the max allowed, if not, then an overflow occured
                ja overflow_a
                ;if there is nothing there, we just exit (and we for some reason jump to the overflow error exit)
                test al, al
                jz overflow_a

                ;Write to the buffer
                mov si, PSP_Arg
                mov di, offset buffer
                mov ah, Delimit
                call write_read

         Read_File_Name_Start:
                   mov si, di ;will equal the uh idk
         Read_File_Name:
                   ;If New_File equals 0ffffh, then we quit the loop
                   mov ax, 0d20h ;Space Character
                   call Find_End ;I believe this is the true search, where it is located.
                   ;di I think stores the filename, I can't exactly remember how I wrote this
                   ;Ok, So we've found the character where it ends and begins,
                   ;yay!
                   mov dx, di ;The filename is in di, so we give dx that
                   push si
                   push di
         Open_File_First: ;Opens the File

                   ;We're going to use a slightly more complicated method
                   ;for finding said file
                   ;that is by using the 9E to get the filename
                   ;and that will search for those pesky '*' commands
                   mov ah, 4Eh ;we'll call the interupt for searching..
                   int 21h ;That writes to 80h. 9e should have the file
         
                  jc quit ;if not, we go here
          Loop_Open_File:
                   ;Now we open the FileName in the DTA Area.

                   
                   cmp [ds: is_drive], 01h
                   jz write_drive_isdrive
          Loop_Open_File_J:
                   mov dx, 9Eh ;Filename stored in the DTA Area
;                  mov ah, Open_File
          Open_File_Fr:
                   mov ah, Open_File
                   xor cx, cx
                   xor al, al
                   int 21h
                   jc quit ;"Just in case", sanity check
                   mov bx, ax
                   jmp Read_File_Start

          write_drive_isdrive:
                        ;push bp
                        ;push di
                        ;mov bp, offset file_head
                        mov dx, di
                        jmp Open_File_Fr
                        ;di already has the file_name

          Read_File_Start:
                   mov dx, offset byte_buf ;dx won't get modified
          Read_File:
                   ;Reads File
                   mov cl, 1h
                   mov ah, 3Fh ;Read time
                   int 21h
          Print_Character:
                   test ax, ax
                   ;we're done reading this file if ax is zero
                   jz Done_File

                   ;If not, read it
                   push dx
                   push bp
                   mov bp, dx
                   mov ah, [bp]

                   mov dl, ah ;Read this
                   mov ah, 02h
                   int 21h
                   ;Boom
                   pop bp
                   pop dx
                   jmp Read_File 
              quit:
                   xor al, al
                   mov ah, 4ch
                   int 21h

                   overflow_a:
                        jmp overflow
          Done_File:
                   mov ah, 3Eh
                   int 21h
                   ;Either get the next one or something
                   ;Closed the file, but is it over yet? Of course not!
                   ;We'll  test if there is any more files left!
                   mov ah, 4Fh ;Indicates search more
                   int 21h 
                   jnc Loop_Open_File ;If we're not done, obviously read more
                   pop di
                   pop si
                   mov di, [ds: Next_File] ;Lets read the next file
                   mov si, di
                   cmp di, 0FFFFh
                   jnz Read_File_Name
                   ret


         ;"Extra" Functions
         Find_End: ;Modifies Si. Does Wrie Si. Ah and Al is delimitor
         ;ah stores character that won't get removed
         Find_Start:
                cmp [si+1], al
                jz Find_Detect

                cmp [si+1], ah
                jz Find_Actual_End

                inc si

                jmp Find_Start
         Find_Detect:
                ;Get rid of whitespace to find the new word
                push si ;Store this
                inc si ;This already is whitespace
                push cx
                mov cl, 00h
                mov [si], cl ;set it to sero
                
         Find_Remove_Whitespace:
                inc si
                cmp [si], al ;If it equals whitespace, we'll ignore it
                jnz Find_Done_Whitespace
                mov [si], cl

         Find_Done_Whitespace:
                pop cx ;restore cx
                mov [ds: Next_File], si
                pop si
                jmp Find_Ret

         Find_Actual_End:
                ;We're going to now replace 0dh sadly with 00h
                ;We're going to add it to the next part
                ;since uh yeah
                push cx
                mov ch, 00h
                mov [si+1], ch
                pop cx 
                mov [ds: Next_File], 0FFFFh
        Find_Ret:
                ;jmp quit
                ret
        overflow:  ;todo
                    jmp quit
                ret
        input:     ;todo
                 jmp quit
                ret
        write_read: ;Reading and Writting. SI = In, DI=Out, CX=End of DI
                    ;ah = Delimitor

                   push si
                   push di
                   push dx
        write_loop:
                   
                   mov dl, [si]

                   mov [di], dl ;Copies from the input to the output

                   cmp dl, Delimit

                   jz write_done

                   cmp dl, '\'
                   jz file_found

                   cmp dl, '/'
                   jz file_found

        renter_lp:
                   inc di
                   inc si
                   jmp write_loop
        file_found:
                   ;drive_end
                   mov [ds: drive_end], di ;now have it equal to this

                   push cx
                   mov cl, 01h
                   mov [ds: is_drive], cl
                   pop cx

                   jmp renter_lp
        write_done:
                   mov cx, di ;It now equals the end
                   pop dx
                   pop di
                   pop si
                   ret



ends
	end start
