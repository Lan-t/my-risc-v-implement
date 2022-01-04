# Risc v implement by VHDL

## implemented instruction

- LUI

- ADDI
- SLTI
- SLTIU
- XORI
- ORI
- ANDI

- JAL
- JALR
- AUIPC

- ADD
- SLT
- SLTU
- XOR
- OR
- AND

- BEQ

- LW
- SW

## remain

- シフトI
- シフト
- SUB
- branch (BEQ以外)
- load (word以外)
- store (word以外)
- system
- fence


## make instruction rom

``` sh
$ cd test_programs
$ ./maketestfile test.c test
$ mv test.txt ../src/external/InstructionRom.txt
```
