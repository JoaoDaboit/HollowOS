# HollowOS

> "Um sistema que nasce oco... para que o usuário preencha com sua identidade."

## Sobre o projeto
HollowOS é um sistema operacional minimalista e customizável, desenvolvido do zero em Assembly x86, com foco em performance, leveza e arquitetura de baixo nível.  
O projeto demonstra conhecimento profundo em sistemas operacionais, bootloaders e manipulação de memória.

## Funcionalidades principais
- **Bootloader de 512 bytes**: Carrega o kernel maior a partir do disco.
- **Kernel de 16 bits com shell interativo**:
  - Comandos: `ajuda`, `sobre`, `autor`, `clear`, `reiniciar`, `go32`
  - Controle de vídeo direto, cursor e suporte a backspace
- **Transição para 32 bits**: Implementação de GDT (Global Descriptor Table) e entrada no Modo Protegido
- **Arquitetura modular**: Bootloader e kernel separados para fácil manutenção e expansão

## Tecnologias utilizadas
- Assembly x86
- NASM
- QEMU
- Linux terminal

## Como compilar e testar

1. Montar o bootloader
```bash
nasm -f bin boot.asm -o boot.img
nasm -f bin kernel.asm -o kernel.bin
cat boot.img kernel.bin > hollowos.img
qemu-system-x86_64 -vga std -fda hollowos.img
