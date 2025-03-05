#!/bin/bash

# Step 1: Create the assembly file
cat << 'EOF' > hello.asm
; hello.asm - A simple .com file example

org 0x100  ; Origin, .com files start at offset 0x100

start:
    mov ah, 0x09  ; DOS print string function
    lea dx, msg   ; Load address of message
    int 0x21      ; DOS interrupt

    mov ax, 0x4C00  ; DOS terminate program
    int 0x21        ; DOS interrupt

msg db 'Hello, World!$'  ; Message to print, $ is the string terminator
EOF

# Step 2: Assemble the file into a .com file using NASM
nasm -f bin hello.asm -o hello.com

# Step 3: Run the .com file using DOSBox
dosbox -c "mount c $(pwd)" -c "c:" -c "hello.com" -c "exit"