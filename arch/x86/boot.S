#include "multiboot.h"

.code32
.section .multiboots
    .long MB_MAGIC
    .long MB_ALIGNED_4K_MEM_MAP
    .long CHECKSUM(MB_ALIGNED_4K_MEM_MAP)

.section .bss
    /* According to System V ABI, the stack must be aligned at 16 bytes boundary*/
    .align 16
    stack_bottom:
        .skip 16384, 0
    stack_top:

.section .text
    .global start_
    start_:
        movl $stack_top, %esp
        /*
            todo: kernel init
                1.load GDT,IDT
                2.Enable paging
        */
        call _kernel_init

        pushl %ebx
        call _kernel_main

        cli
    j_:
        hlt
        jmp j_