.text

.global _start
_start:
    addi t0, x0, 0
    addi sp, sp, -4

    label:

    addi t0, t0, 1
    sw t0, 0(sp)

    jal x0, label


