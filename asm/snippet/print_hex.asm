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

