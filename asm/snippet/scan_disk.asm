scan_start: ;AX = drive,CX = cylinder + sec
        push dx ;stores max num of head + drive
        push es ;for sanity check I guess
        push di ;again, I guess sanity check
        push bx ;drive type

        xor  ax, ax

        push ax
        pop es

        xor di, di
loop_start:
        mov ah, 0x08 ;get parameters
        int 0x13

        cmp dl, 0x7c ;maximum drivers to read
        jz exit_fail ;if it equals 7c, give up

        inc dl;search for drive
        cmp bl, 0x04 ;04 = 1.44 mb floppy drive
        jnz loop_start
found_floppy: ;successfully found the drive!
        xor ax, ax
        xchg al, dl ;Successful drive 
exit:
        pop bx
        pop di
        pop es
        pop dx
        ret 
exit_fail: ;failed to search
        xor ax, ax
        jmp exit
