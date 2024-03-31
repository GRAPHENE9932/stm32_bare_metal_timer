.section .text
.global tim3_initialize
.global tim3_reset_int_flag

.equ TIM3_BASE, 0x40000400
.equ TIM2_3_PSC_OFFSET, 0x00000028
.equ TIM2_3_ARR_OFFSET, 0x0000002C
.equ TIM2_3_CCR2_OFFSET, 0x00000038
.equ TIM2_3_CCMR1_OFFSET, 0x00000018
.equ TIM2_3_CCER_OFFSET, 0x00000020
.equ TIM2_3_CR1_OFFSET, 0x00000000
.equ TIM2_3_EGR_OFFSET, 0x00000014
.equ TIM2_3_DIER_OFFSET, 0x0000000C
.equ TIM2_3_SR_OFFSET, 0x00000010

.equ TIM3_PRESCALER, 1000                   @ 8000 Hz at clock frequency of 8 MHz.
.equ TIM3_ARR, 800                          @ Period of exactly 0.1 s (10 Hz).
.equ TIM3_EGR, 0b0000000000000001           @ UG set to 1.
.equ TIM3_DIER, 0b0000000000000001          @ UIE set to 1.
.equ TIM3_CR1, 0b0000000000000001           @ CEN set to 1, CMS set to 00 (reset value), DIR to 0 (reset value).

.equ RCC_BASE, 0x40021000
.equ RCC_APB1ENR_OFFSET, 0x0000001C

.equ EXTI_BASE, 0x40010400
.equ EXTI_IMR_OFFSET, 0x00000000
.equ EXTI_EMR_OFFSET, 0x00000004
.equ EXTI_SWIER_OFFSET, 0x00000010

.equ ISER_ADDRESS, 0xE000E100

.type enable_tim3_clock, %function
enable_tim3_clock:
    ldr R0, =RCC_BASE + RCC_APB1ENR_OFFSET  @ R0 stores the RCC_APB1ENR register location.
    ldr R1, [R0]                            @ R1 stores the RCC_APB1ENR register value.

    ldr R2, =0x00000002                     @ R2 stores the OR mask (TIM3EN=1).
    orr R1, R1, R2
    str R1, [R0]

    bx LR

.type tim3_reset_int_flag, %function
tim3_reset_int_flag:
    ldr R0, =TIM3_BASE + TIM2_3_SR_OFFSET   @ R0 stores the TIM3_SR register location.
    ldr R1, [R0]                            @ R1 stores the TIM3_SR register value.
    ldr R2, =0xFFFFFFFE                     @ Setting UIF=0.
    and R1, R1, R2
    str R1, [R0]

    bx LR

.type tim3_initialize, %function
tim3_initialize:
    push {LR}

    bl enable_tim3_clock

    @ Set prescaler to the TIM3_PRESCALER value.
    ldr R0, =TIM3_BASE + TIM2_3_PSC_OFFSET
    ldr R1, =TIM3_PRESCALER
    str R1, [R0]

    @ Set auto reload register to the TIM3_ARR value.
    ldr R0, =TIM3_BASE + TIM2_3_ARR_OFFSET
    ldr R1, =TIM3_ARR
    str R1, [R0]

    @ Set event generation register to the TIM3_EGR value.
    ldr R0, =TIM3_BASE + TIM2_3_EGR_OFFSET
    ldr R1, =TIM3_EGR
    str R1, [R0]

    @ Set DMA/Interrupt enable register to the TIM3_DIER value.
    ldr R0, =TIM3_BASE + TIM2_3_DIER_OFFSET
    ldr R1, =TIM3_DIER
    str R1, [R0]

    @ Set control register 1 to the TIM3_CR1 value.
    ldr R0, =TIM3_BASE + TIM2_3_CR1_OFFSET
    ldr R1, =TIM3_CR1
    str R1, [R0]

    @ Enable 16th interrupt (TIM3 global interrupt) of the interrupt set-enable register.
    ldr R0, =ISER_ADDRESS
    ldr R1, [R0]
    ldr R2, =0x00010000
    orr R1, R1, R2
    str R1, [R0]

    pop {PC}
