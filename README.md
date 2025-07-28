# HollowOS

> "Um sistema que nasce oco... para que o usuário preencha com sua identidade."

## Sobre o Projeto

HollowOS é um projeto para criar um sistema operacional do zero (from scratch), com foco em performance, leveza e, acima de tudo, customização profunda. A visão é criar um SO que não força o usuário a se adaptar a ele, mas que se molda para ser um reflexo da identidade e do fluxo de trabalho de quem o utiliza.

Este repositório documenta minha jornada de aprendizado e construção, desde o bootloader de 16 bits até um kernel de 32 bits e além.

## Funcionalidades Atuais (Versão 0.1 - "O Casulo")

    Arquitetura de Dois Estágios: Um bootloader de 512 bytes (boot.asm) carrega um kernel maior (kernel.asm) a partir de uma imagem de disco.

    Kernel de 16 bits: Inclui um shell de comando interativo com suporte para múltiplos comandos, incluindo:

        ajuda: Lista os comandos disponíveis.

        sobre: Mostra a filosofia do SO.

        autor: Exibe informações do criador.

        clear: Limpa a tela.

        reiniciar: Reinicia a máquina.

        go32: Inicia a transição para o Modo Protegido.

    Controle de Baixo Nível: Manipulação direta da memória de vídeo para cores, controle do cursor e suporte a backspace.

    Transição para 32 bits: Implementação e carregamento de uma GDT (Global Descriptor Table) para entrar com sucesso no Modo Protegido de 32 bits.

## Como Compilar e Testar

Este projeto é montado com o NASM e testado com o QEMU em um ambiente Linux.

# 1. Montar o bootloader
nasm -f bin boot.asm -o boot.img

# 2. Montar o kernel
nasm -f bin kernel.asm -o kernel.bin

# 3. Juntar os arquivos em uma imagem de disco
cat boot.img kernel.bin > hollowos.img

# 4. Executar na máquina virtual
qemu-system-x86_64 -vga std -fda hollowos.img
