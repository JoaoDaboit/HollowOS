[org 0x7c00]
[bits 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov si, msg_loading
    call print_simple

    mov ah, 0x02
    mov al, 16
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0
    mov bx, KERNEL_ADDR
    int 0x13
    jc hang

    jmp KERNEL_ADDR

print_simple:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp print_simple
.done:
    ret

hang:
    jmp hang

msg_loading db 'Carregando HollowOS...', 0
KERNEL_ADDR equ 0x8000

times 510-($-$$) db 0
dw 0xAA55