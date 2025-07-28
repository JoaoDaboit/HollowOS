[org 0x8000]
[bits 16]

start_shell:
    call newline
    mov si, prompt
    call print_string_roxo
    mov di, command_buffer

.read_char_loop:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D
    je .process_command
    cmp ah, 0x0E
    je .handle_backspace
    mov [di], al
    inc di
    mov ah, 0x0e
    mov bh, 0x00
    mov bl, 0x05
    int 0x10
    jmp .read_char_loop

.process_command:
    mov byte [di], 0
    mov si, command_buffer
    mov di, go32_cmd
    call strcmp
    cmp ax, 0
    je .do_go32
    mov si, command_buffer
    mov di, ajuda_cmd
    call strcmp
    cmp ax, 0
    je .show_help
    mov si, command_buffer
    mov di, hollow_cmd
    call strcmp
    cmp ax, 0
    je .show_hollow
    mov si, command_buffer
    mov di, clear_cmd
    call strcmp
    cmp ax, 0
    je .do_clear
    mov si, command_buffer
    mov di, autor_cmd
    call strcmp
    cmp ax, 0
    je .show_autor
    mov si, command_buffer
    mov di, sobre_cmd
    call strcmp
    cmp ax, 0
    je .show_sobre
    mov si, command_buffer
    mov di, reiniciar_cmd
    call strcmp
    cmp ax, 0
    je .reboot
    mov si, msg_desconhecido
    call print_string_magenta
    jmp start_shell

.handle_backspace:
    cmp di, command_buffer
    je .read_char_loop
    dec di
    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .read_char_loop
.show_help:
    mov si, msg_ajuda
    call print_string_magenta
    jmp start_shell
.show_hollow:
    mov si, msg_hollow
    call print_string_magenta
    jmp start_shell
.do_clear:
    mov ah, 0x06
    mov al, 0x00
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10
    jmp start_shell
.show_autor:
    mov si, msg_autor
    call print_string_magenta
    jmp start_shell
.show_sobre:
    mov si, msg_sobre
    call print_string_magenta
    jmp start_shell
.reboot:
    mov al, 0xFE
    out 0x64, al

.do_go32:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:start_32bit

[bits 32]
start_32bit:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov esi, msg_32bit
    mov ebx, 0xb8000
    call print_32bit
    jmp $
print_32bit:
.loop:
    mov al, [esi]
    cmp al, 0
    je .done
    mov ah, 0x0D
    mov [ebx], ax
    add ebx, 2
    inc esi
    jmp .loop
.done:
    ret

[bits 16]
print_string_roxo:
    lodsb
    or al, al
    jz .done_roxo
    mov ah, 0x0e
    mov bh, 0x00
    mov bl, 0x05
    int 0x10
    jmp print_string_roxo
.done_roxo:
    ret
print_string_magenta:
    lodsb
    or al, al
    jz .done_magenta
    mov ah, 0x0e
    mov bh, 0x00
    mov bl, 0x0D
    int 0x10
    jmp print_string_magenta
.done_magenta:
    ret
strcmp:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
    inc si
    inc di
    jmp .loop
.equal:
    mov ax, 0
    ret
.not_equal:
    mov ax, 1
    ret
newline:
    mov ah, 0x0e
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret
hang:
    cli
    hlt

prompt          db 'hollowos~$ ', 0
go32_cmd        db 'go32', 0
ajuda_cmd       db 'ajuda', 0
hollow_cmd      db 'hollow', 0
clear_cmd       db 'clear', 0
autor_cmd       db 'autor', 0
sobre_cmd       db 'sobre', 0
reiniciar_cmd   db 'reiniciar', 0
msg_hollow      db ' Bem vindo ao HollowOS!', 0
msg_ajuda       db ' Comandos: ajuda, hollow, clear, autor, sobre, reiniciar, go32', 0
msg_desconhecido db ' Comando desconhecido.', 0
msg_autor       db ' Autor: Joao Paulo Daboit, 2025', 0
msg_sobre       db ' HollowOS: Um sistema unico para voce customizar do jeito que quiser.', 0
msg_32bit       db 'HollowOS agora esta em Modo Protegido de 32 bits!', 0
command_buffer  resb 64

gdt_start:
gdt_null:
    dq 0x0
gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0b10011010
    db 0b11001111
    db 0x00
gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0b10010010
    db 0b11001111
    db 0x00
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start