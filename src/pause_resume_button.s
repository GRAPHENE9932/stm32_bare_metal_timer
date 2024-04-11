.section .text
.global pause_resume_button_init
.global exti0_1_interrupt_handler

.equ SYSCFG_BASE_ADDRESS, 0x40010000
.equ SYSCFG_EXTICR1_OFFSET, 0x00000008

.equ EXTI_BASE_ADDRESS, 0x40010400
.equ EXTI_IMR_OFFSET, 0x00000000
.equ EXTI_RTSR_OFFSET, 0x00000008
.equ EXTI_PR_OFFSET, 0x00000014

.equ RCC_BASE_ADDRESS, 0x40021000
.equ RCC_APB2ENR_OFFSET, 0x00000018

.equ ISER_ADDRESS, 0xE000E100

@ Enables external interrupt for the rising edge of PORTB0.
@ Takes no arguments, returns nothing.
.type pause_resume_button_init, %function
pause_resume_button_init:
    @ Set RCC_APB2ENR register's SYSCFGCOMPEN value to 1.
    ldr R0, =RCC_BASE_ADDRESS + RCC_APB2ENR_OFFSET          @ R0 stores the RCC_APB2ENR register address.
    ldr R1, [R0]            @ R1 stores the RCC_APB2ENR register value itself.
    ldr R2, =0x00000001     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    @ Set SYSCFG_EXTICR1 register's EXTI0 value to 0001 (PORTB).
    ldr R0, =SYSCFG_BASE_ADDRESS + SYSCFG_EXTICR1_OFFSET    @ R0 stores the SYSCFG_EXTICR1 register address.
    ldr R1, [R0]            @ R1 stores the SYSCFG_EXTICR1 register value itself.
    ldr R2, =0xFFFFFFF0     @ R2 stores the AND mask.
    and R1, R1, R2
    ldr R2, =0x00000001     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    @ Set EXTI_IMR register's IM0 value to 1.
    ldr R0, =EXTI_BASE_ADDRESS + EXTI_IMR_OFFSET            @ R0 stores the EXTI_IMR register address.
    ldr R1, [R0]            @ R1 stores the EXTI_IMR register value itself.
    ldr R2, =0x00000001     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    @ Set EXTI_RTSR register's RT0 value to 1.
    ldr R0, =EXTI_BASE_ADDRESS + EXTI_RTSR_OFFSET           @ R0 stores the EXTI_RTSR register address.
    ldr R1, [R0]            @ R1 stores the EXTI_RTSR register value itself.
    ldr R2, =0x00000001     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    @ Enable 5th interrupt (EXTI Line[1:0] interrupts) of the interrupt set-enable register.
    ldr R0, =ISER_ADDRESS
    ldr R1, [R0]
    ldr R2, =0x00000020
    orr R1, R1, R2
    str R1, [R0]

    bx LR

.type exti0_1_interrupt_handler, %function
exti0_1_interrupt_handler:
    push {LR}
    
    bl toggle_pause

    @ Set EXTI_PR register's PIF0 value to 1.
    ldr R0, =EXTI_BASE_ADDRESS + EXTI_PR_OFFSET @ R0 stores the EXTI_PR register address.
    ldr R1, [R0]            @ R1 stores the EXTI_PR register value itself.
    ldr R2, =0x00000001     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    pop {PC}
