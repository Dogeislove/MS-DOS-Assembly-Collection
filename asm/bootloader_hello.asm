[BITS 16]
ORG 0X7C00

start:
        cli 
        mov     sp, 0x7bfc
        jmp video_setup


video_setup:
        mov ah, 0x00 
        mov al, 0x03 
        int 0x10 ;

        nop 

print_message_start:
        mov si, message
        mov [si], al

print_message_loop:
        lodsb 
print_message_check:

        test al, al 
        jz repeat_jump 
print_message_character:
        mov ah, 0x0E
        int 0x10 
        jmp print_message_loop
repeat_jump:
        hlt
        jmp repeat_jump 
return_bootloader:
        ret 


message: db "Hello", 0"

;First non-tasm program ever made by me.
