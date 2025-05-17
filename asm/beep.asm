
;org 100h
.model small
stack 0ffffh
.code
org 100h
;TIMER_INT = 1ch

start:
       call beep_setup
       ; ~2 sec
       mov ax, 2000h
       mov bx, 36h
       call beep_play
       mov ax, 2001h
       mov bx, 36h
       call beep_play ;emotional, you may cry due to the song i certianly did
       xor ax, ax
       int 16h
       call beep_teardown
       mov ax, 4c00h
       int 21h ;return
       ret
beep_setup:
        push es
        push ax

        xor ax, ax
        mov es, ax
        mov ax, WORD [es: TIMER_INT * 4]
        mov WORD [cs: original_timer_isr], ax
        mov ax, WORD [es: TIMER_INT * 4 + 2]
        mov WORD [cs: original_timer_isr + 2], ax
        ;set the new isr, i forgot what that was oof

        ;interupts may frick up some stuff so lets disable it
        cli
        mov ax, offset beep_isr ;idk why we're moving the address of beep_isr here
        ;mov ax, WORD [cs: original_timer_isr]
        mov WORD [es: TIMER_INT*4], ax
        mov ax, cs
        ;mov ax,WORD [cs: original_timer_isr+2]
        mov WORD [es: TIMER_INT * 4 + 2], ax
        sti ;

        pop ax
        pop es
        ret
;Break the ISR :sunglasses:
beep_teardown:
        push es
        push ax

        call beep_stop ;probably want to stop if you are to break down somethin

        xor ax, ax
        mov es, ax

        ;RESTORE LE OLD ISR!
        cli
        mov ax, WORD [cs: original_timer_isr]
        mov WORD [es: TIMER_INT * 4], ax
        mov ax, WORD [cs: original_timer_isr + 2]
        mov WORD [es: TIMER_INT*4 + 2], ax
        sti
        pop ax
        pop es
        ret
beep_isr:
        cmp BYTE [sound_playing], 0
        je _bi_end

        cmp WORD [sound_counter], 0
        je _bi_stop

        dec WORD [sound_counter]
        jmp _bi_end
_bi_stop:
        call beep_stop
_bi_end:
        jmp start
beep_stop:
        push ax

        in al, 61h ;the port that controls PIT, we're reading from
        and al, 0fch ;Some AND logic stuff. IT clears bit 0 and sets bit 1 to enable spaker
        out 61h, al

        mov BYTE [sound_playing], 0

        pop ax
        ret
;AX = 1193180 / frequency
beep_play: ;play the beep. BX = duration in 18.2 of a sec
        push ax
        push dx

        mov dx, ax

        mov al, 0b6h
        out 43h, al

        mov ax, dx
        out 42h, al
        mov al, ah
        out 42h, al

        ;the finaly count down dododododododododododododododo
        ;we set it! yay!
        mov WORD [cs:sound_counter], bx

        ;Start thy sound
        ;First we read the input and yay
        in al, 61h
        or al, 3h ;SET BIT 0 (PIT TO SPEAKER) AND BIT 1 (SPEAKER ENABLED)
        out 61h, al

        ;START THE CONTDOWN DODODODODODODODODODODODODO
        mov BYTE [sound_playing], 1
        pop dx
        pop ax
        ret


sound_playing db 00h
sound_counter dw 0000h
original_timer_isr dw 0

TIMER_INT EQU 1ch
end start
