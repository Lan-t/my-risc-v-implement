# Risc v implement by VHDL

## implemented instruction

- LUI

- ADDI
- SLTI
- SLTIU
- XORI
- ORI
- ANDI
- SLLI
- SRLI
- SRAI

- JAL
- JALR
- AUIPC

- ADD
- SUB
- SLT
- SLTU
- XOR
- OR
- AND
- SLL
- SRL
- SRA

- BEQ

- LW
- SW

## remain

- branch (BEQ以外)
- load (word以外)
- store (word以外)
- system
- fence


## make instruction rom

``` sh
$ cd test_programs
$ ./maketestfile test.c test
$ mv test.txt ../src/external/mem_file/InstructionRom.txt
$ cd ..
```
