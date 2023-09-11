        .section .text.init
        .globl _start
_start:
        /*.option push
        .option norelax
        la gp, __global_pointer$
        .option pop
        /* Set SP (i.e stack) to 0x00008000_00010000 */

        li t0, 0x8000010000    # Load the desired value into temporary register t0
    	mv sp, t0              # Move the value from t0 to the stack pointer register sp
        j main

/* .section .bss

.align 4

_stack_bottom:
        .space 8000

.align 8
_stack_top: */
