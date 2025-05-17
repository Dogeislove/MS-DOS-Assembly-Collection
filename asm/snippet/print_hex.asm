print_hex: ;The new and improved version. CX WILL ALWAYS BE MODIFIED, for efficency.
        push bp
        mov bp, sp
        mov cx, 0x04
        mov ax, [bp+4]
print_hex_loop:
        ;Iterating over each piece
        rol ax, 0x04
        ;Since AX is not meant to be changed, we put it in CX, where we will print our character
        mov bp, ax

        ;Get the bits we want, and print it
        and bp, 0x000F
        ;We can temporarly store al in cl, where we know it doesn't get modified. Since we need to preserve al, and not cl, we'll put it in cl, and exchange what cl would be later
        xchg ax, bp

        ; CONVERSION FUNCTION. Embedded into the code to save a single byte.
        cmp al, 0x0a
        sbb al, 0x69
        das
        call print

        xchg bp, ax
        ;Checks and see if we have finally re-entered the start of the loop. If so, we don't jump
        loop print_hex_loop
        pop bp
        ret
```

```x86asm
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
        jmp exit ```
