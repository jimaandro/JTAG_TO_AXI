#!/bin/bash

if [[ $# -lt 1 ]]; then
	echo "Syntax: <output hex file>"
	exit
fi 



CFLAGS="-march=rv64ima -mabi=lp64 -mcmodel=medany -mexplicit-relocs -mstrict-align -malign-data=xlen"

/opt/riscv/bin/riscv64-unknown-elf-gcc ${CFLAGS}  -Wa,-a  -nostartfiles -T link.ld -o main.elf entry.s main.cpp
/opt/riscv/bin/riscv64-unknown-elf-objcopy -O binary --only-section=".text" main.elf  main.bin
/opt/riscv/bin/riscv64-unknown-elf-objdump -d main.elf > Main.dump
hexdump -e  '/4 "%8.8X \n"'  main.bin > $1

sed 's/ //g' $1 > inputf.hex

rm $1
rm main.bin
rm main.elf

