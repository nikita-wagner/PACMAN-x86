org 0x7c00      ; Start position for boot sector

; Set up the game environment
mov ax,0x0013   ; Set mode 0x13 (320x200x256 VGA)
int 0x10        ; Call BIOS
cld
mov ax,0xa000   ; Point to screen memory
mov ds,ax       ; Both DS...
mov es,ax       ; ...and ES

; Initialize game variables
mov word [player_x],160   ; Player X position (initial position at the center of the screen)
mov word [player_y],100   ; Player Y position (initial position at the center of the screen)

; Main game loop
game_loop:
    ; Handle player movement
    mov ah,0x01                 ; BIOS Check for Keystroke
    int 0x16
    jz no_key_pressed           ; No key pressed, jump to no_key_pressed
    mov ah,0x00                 ; BIOS Get Keystroke
    int 0x16
    ; 'al' now contains the ASCII code of the key pressed

    cmp al,'w'                  ; W key?
    je set_move_up              ; If W key, jump to set_move_up
    cmp al,'s'                  ; S key?
    je set_move_down            ; If S key, jump to set_move_down
    cmp al,'a'                  ; A key?
    je set_move_left            ; If A key, jump to set_move_left
    cmp al,'d'                  ; D key?
    je set_move_right           ; If D key, jump to set_move_right
    jmp no_key_pressed          ; If no valid key, jump to no_key_pressed

set_move_up:
    mov byte [move_up_flag], 1
    jmp no_key_pressed

set_move_down:
    mov byte [move_down_flag], 1
    jmp no_key_pressed

set_move_left:
    mov byte [move_left_flag], 1
    jmp no_key_pressed

set_move_right:
    mov byte [move_right_flag], 1
    jmp no_key_pressed

no_key_pressed:
    ; Update player position based on key flags
    cmp byte [move_up_flag], 0
    je check_move_down
    dec word [player_y]

check_move_down:
    cmp byte [move_down_flag], 0
    je check_move_left
    inc word [player_y]

check_move_left:
    cmp byte [move_left_flag], 0
    je check_move_right
    dec word [player_x]

check_move_right:
    cmp byte [move_right_flag], 0
    je update_position
    inc word [player_x]

update_position:
    ; Clear previous pixel
    mov di,word [prev_pixel]    ; Load previous pixel offset
    mov byte [es:di],0          ; Clear pixel

    ; Calculate new pixel offset
    mov ax,word [player_y]      ; Load player Y position
    mov bx,320                  ; Load screen width
    mul bx                      ; Multiply Y position by screen width
    add ax,word [player_x]      ; Add player X position
    mov di,ax                   ; Store new pixel offset
    mov word [prev_pixel],di    ; Update previous pixel offset

    ; Draw player pixel
    mov byte [es:di],15         ; Draw white pixel

    ; Delay to control game speed
    mov cx,0xffff               ; Delay counter
    delay_loop:
        loop delay_loop         ; Decrement CX and loop until zero

    jmp game_loop               ; Continue the game loop

; Variables
player_x dw 0                   ; Player X position
player_y dw 0                   ; Player Y position
prev_pixel dw 0                 ; Previous pixel offset
move_up_flag db 0               ; Flag for moving up
move_down_flag db 0             ; Flag for moving down
move_left_flag db 0             ; Flag for moving left
move_right_flag db 0            ; Flag for moving right

times 510-($-$$) db 0           ; Pad the boot sector with zeros
dw 0xaa55                       ; Boot sector signature