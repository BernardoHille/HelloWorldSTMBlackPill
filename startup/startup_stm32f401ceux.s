/* Minimal startup for STM32F401CEU6 (Cortex-M4) */

    .syntax unified
    .cpu cortex-m4
    .thumb

/* Stack (1 KB) and heap (512 B) */
    .equ    Stack_Size, 0x400
    .section .stack, "w", %nobits
    .align 3
__StackLimit:
    .space  Stack_Size
    .global __StackTop
__StackTop:

    .equ    Heap_Size, 0x200
    .section .heap, "w", %nobits
    .align 3
__HeapBase:
    .space  Heap_Size
__HeapLimit:

/* Vector table */
    .section .isr_vector, "a", %progbits
    .type   g_pfnVectors, %object
    .global g_pfnVectors
g_pfnVectors:
    .word   __StackTop
    .word   Reset_Handler
    .word   NMI_Handler
    .word   HardFault_Handler
    .word   MemManage_Handler
    .word   BusFault_Handler
    .word   UsageFault_Handler
    .word   0
    .word   0
    .word   0
    .word   0
    .word   SVC_Handler
    .word   DebugMon_Handler
    .word   0
    .word   PendSV_Handler
    .word   SysTick_Handler
    .rept   84
    .word   Default_Handler
    .endr

/* Reset handler */
    .text
    .thumb_func
    .global Reset_Handler
    .type   Reset_Handler, %function
Reset_Handler:
    ldr     r0, =_sdata
    ldr     r1, =_edata
    ldr     r2, =_sidata
    b       copy_check
copy_loop:
    ldr     r3, [r2], #4
    str     r3, [r0], #4
copy_check:
    cmp     r0, r1
    bcc     copy_loop

    ldr     r0, =_sbss
    ldr     r1, =_ebss
    movs    r2, #0
    b       bss_check
bss_loop:
    str     r2, [r0], #4
bss_check:
    cmp     r0, r1
    bcc     bss_loop

    bl      main

infinite_loop:
    b       infinite_loop

    .size   Reset_Handler, . - Reset_Handler

/* Default handler loops forever; override by redefining the symbol. */
    .thumb_func
    .global Default_Handler
    .weak   Default_Handler
    .type   Default_Handler, %function
Default_Handler:
    b       Default_Handler
    .size   Default_Handler, . - Default_Handler

    .macro  WEAK_ALIAS name
    .weak   \name
    .thumb_set \name, Default_Handler
    .endm

    WEAK_ALIAS NMI_Handler
    WEAK_ALIAS HardFault_Handler
    WEAK_ALIAS MemManage_Handler
    WEAK_ALIAS BusFault_Handler
    WEAK_ALIAS UsageFault_Handler
    WEAK_ALIAS SVC_Handler
    WEAK_ALIAS DebugMon_Handler
    WEAK_ALIAS PendSV_Handler
    WEAK_ALIAS SysTick_Handler
