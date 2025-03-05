#!/bin/bash

# Assemble the bootloader
nasm -f bin -o bootloader.bin bootloader.asm

# Assemble the second stage
nasm -f bin -o game.bin game.asm

# Create a blank floppy disk image
dd if=/dev/zero of=bootloader.img bs=512 count=2880

# Write the bootloader to the first sector
dd if=bootloader.bin of=bootloader.img conv=notrunc

# Write the second stage to the second sector
dd if=game.bin of=bootloader.img bs=512 seek=1 conv=notrunc

if [ "$1" == "-d" ]; then
  echo "Building debug version..."

  qemu-system-x86_64 -s -S -drive format=raw,file=bootloader.img -icount shift=1 &

  # Wait a moment to ensure QEMU has started
  sleep 2

  # Launch another MSYS2 terminal and run GDB with the script
  mintty -e gdb -x debug_script.gdb

elif [ "$1" == "-n" ]; then
  echo "Building non-debug version..."

  qemu-system-x86_64 -drive format=raw,file=bootloader.img -icount shift=1
else
  echo "Invalid argument. Use '-d' or '-n'."
  exit 1
fi