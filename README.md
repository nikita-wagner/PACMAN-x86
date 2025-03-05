# Bootable Game Build Script and MSYS2 Usage

This project demonstrates how to build a bootable game using a bootloader and a second-stage game binary. The build process is managed by a shell script that assembles the bootloader and game code with NASM, creates a blank floppy disk image, writes the bootloader and game to the image, and then launches QEMU for emulation. You also have the option to build a debug version that uses GDB for debugging.

---

## Build Script Overview

The provided build script (`build.sh`) performs the following actions:

1. **Assemble the Bootloader and Game:**
   - Uses NASM to assemble `bootloader.asm` into `bootloader.bin`.
   - Uses NASM to assemble `game.asm` into `game.bin`.

2. **Create a Floppy Disk Image:**
   - Runs `dd` to produce a 1.44 MB image (2880 sectors × 512 bytes).

3. **Write the Bootloader and Game Binaries:**
   - Writes `bootloader.bin` to the first sector of the disk image.
   - Writes `game.bin` to the second sector (using a 512-byte block size and seek).

4. **Launch QEMU:**
   - If the script is called with `-d`, it will launch QEMU with debugging enabled (`-s -S`) and then open an MSYS2 terminal (mintty) that starts GDB with your provided script (`debug_script.gdb`).
   - If called with `-n`, it launches QEMU in a normal, non-debug configuration.

### Build Script (`build.sh`) Example

```bash
#!/bin/bash
# Assemble the bootloader
nasm -f bin -o bootloader.bin bootloader.asm
# Assemble the second stage
nasm -f bin -o game.bin game.asm

# Create a blank floppy disk image (1.44 MB)
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
    # Open a new MSYS2 terminal and run GDB with the provided debug script
    mintty -e gdb -x debug_script.gdb
elif [ "$1" == "-n" ]; then
    echo "Building non-debug version..."
    qemu-system-x86_64 -drive format=raw,file=bootloader.img -icount shift=1
else
    echo "Invalid argument. Use '-d' for debug or '-n' for non-debug."
    exit 1
fi