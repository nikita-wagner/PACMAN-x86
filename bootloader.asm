; bootloader.asm
bits 16
org 0x7c00

start:
    mov ah, 0x02       ; BIOS function to read sectors
    mov al, 4          ; Number of sectors to read (adjust this based on the size of pacman.asm)
    mov ch, 0          ; Cylinder number (0)
    mov cl, 2          ; Sector number (2, assuming the second stage starts from the second sector)
    mov dh, 0          ; Head number (0)
    mov bx, 0x9000     ; Destination buffer address (0x9000, where pacman.asm will be loaded)
    int 0x13           ; BIOS interrupt to read from disk
    jmp 0x9000         ; Jump to the loaded pacman.asm at address 0x9000

times 510-($-$$) db 0  ; Fill the rest of the boot sector with zeros
dw 0xaa55              ; Boot signature (0xAA55)