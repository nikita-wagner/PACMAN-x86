# debug_script.gdb
# Disable pagination
set pagination off
# Connect to the QEMU GDB server
target remote localhost:1234


# Set a breakpoint at the start of the bootloader
break *0x9099
#

c

# x/i $pc
# Define a loop to disassemble instructions in real-time

define disassemble_realtime
  while 1


    # Continue execution until the breakpoint is hit
    # c


    # Print register values
    info registers


    x/i $pc
    si
    # Step to the next instruction
    # Sleep for a short period to make the output readable
    shell sleep 0.01
  end
end
# Call the loop to disassemble instructions
disassemble_realtime