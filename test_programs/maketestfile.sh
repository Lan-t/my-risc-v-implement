#!/bin/sh

TOOLCHAIN_PREFIX="riscv32-unknown-linux-gnu-"
GCC="${TOOLCHAIN_PREFIX}gcc"
OBJCOPY="${TOOLCHAIN_PREFIX}objcopy"
OBJDUMP="${TOOLCHAIN_PREFIX}objdump"


inputfile=${1}
outputfile=${2}

${GCC} -nostdlib ${inputfile} -o ${outputfile} -T linker.ld
${OBJCOPY} -O binary --only-section=.text ${outputfile} ${outputfile}.bin
xxd -e -c 4 ${outputfile}.bin | cut -d " " -f 2 > ${outputfile}.txt
${OBJDUMP} -b binary -m riscv:rv32 -D ${outputfile}.bin

rm ${outputfile} ${outputfile}.bin
