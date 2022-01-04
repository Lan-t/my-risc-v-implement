.text

.global _start
_start:
    lui t1, 0x12345
    ori t2, t1, 0x678
    addi t3, t1, 0x678
    auipc t4, 0x120

    addi t5, x0, 4
    sw t2, 8(t5)
    lw t6, 8(t5)

    # addi r5, r0, 12
    # add r6, r0, r0
    # L1:

