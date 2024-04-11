.section .text
.global plus_30_secs_button_init
.global exti4_15_interrupt_handler

.equ SYSCFG_BASE_ADDRESS, 0x40010000
.equ SYSCFG_EXTICR2_OFFSET, 0x0000000C

.equ EXTI_BASE_ADDRESS, 0x40010400
.equ EXTI_IMR_OFFSET, 0x00000000
.equ EXTI_RTSR_OFFSET, 0x00000008
.equ EXTI_PR_OFFSET, 0x00000014

.equ RCC_BASE_ADDRESS, 0x40021000
.equ RCC_APB2ENR_OFFSET, 0x00000018

.equ ISER_ADDRESS, 0xE000E100

@ Enables external interrupt for the rising edge of PORTB7.
@ Takes no arguments, returns nothing.
.type plus_30_secs_button_init, %function
plus_30_secs_button_init:
    @ Set RCC_APB2ENR register's SYSCFGCOMPEN value to 1.
    ldr R0, =RCC_BASE_ADDRESS + RCC_APB2ENR_OFFSET          @ R0 stores the RCC_APB2ENR register address.
    ldr R1, [R0]            @ R1 stores the RCC_APB2ENR register value itself.
    ldr R2, =0x00000001     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    @ Set SYSCFG_EXTICR2 register's EXTI7 value to 0001 (PORTB).
    ldr R0, =SYSCFG_BASE_ADDRESS + SYSCFG_EXTICR2_OFFSET    @ R0 stores the SYSCFG_EXTICR2 register address.
    ldr R1, [R0]            @ R1 stores the SYSCFG_EXTICR2 register value itself.
    ldr R2, =0xFFFF0FFF     @ R2 stores the AND mask.
    and R1, R1, R2
    ldr R2, =0x00001000     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    @ Set EXTI_IMR register's IM7 value to 1.
    ldr R0, =EXTI_BASE_ADDRESS + EXTI_IMR_OFFSET            @ R0 stores the EXTI_IMR register address.
    ldr R1, [R0]            @ R1 stores the EXTI_IMR register value itself.
    ldr R2, =0x00000080     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    @ Set EXTI_RTSR register's RT7 value to 1.
    ldr R0, =EXTI_BASE_ADDRESS + EXTI_RTSR_OFFSET           @ R0 stores the EXTI_RTSR register address.
    ldr R1, [R0]            @ R1 stores the EXTI_RTSR register value itself.
    ldr R2, =0x00000080     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    @ Enable 7th interrupt (EXTI Line[4:15] interrupts) of the interrupt set-enable register.
    ldr R0, =ISER_ADDRESS
    ldr R1, [R0]
    ldr R2, =0x00000080
    orr R1, R1, R2
    str R1, [R0]

    bx LR

.type exti4_15_interrupt_handler, %function
exti4_15_interrupt_handler:
    push {LR}
    
    bl add_30_secs

    @ Set EXTI_PR register's PIF7 value to 1.
    ldr R0, =EXTI_BASE_ADDRESS + EXTI_PR_OFFSET @ R0 stores the EXTI_PR register address.
    ldr R1, [R0]            @ R1 stores the EXTI_PR register value itself.
    ldr R2, =0x00000080     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    pop {PC}
