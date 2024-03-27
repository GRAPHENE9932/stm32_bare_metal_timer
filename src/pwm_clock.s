.section .text
.global tim2_pwm_initialize
.global enable_pwm_clock

.equ GPIOB_BASE, 0x48000400
.equ GPIOX_AFRL_OFFSET, 0x00000020

.equ TIM2_BASE, 0x40000000
.equ TIM2_PSC_OFFSET, 0x00000028
.equ TIM2_ARR_OFFSET, 0x0000002C
.equ TIM2_CCR2_OFFSET, 0x00000038
.equ TIM2_CCMR1_OFFSET, 0x00000018
.equ TIM2_CCER_OFFSET, 0x00000020
.equ TIM2_CR1_OFFSET, 0x00000000
.equ TIM2_EGR_OFFSET, 0x00000014

.equ TIM2_PRESCALER, 1000                   @ 8000 Hz at clock frequency of 8 MHz.
.equ TIM2_ARR, 10                           @ Period of 1250 us (800 Hz).
.equ TIM2_CCR2, 5                           @ Capture/compare register. Half of the TIM_ARR, so the PWM duty cycle is 50%.
.equ TIM2_CCMR1, 0b0110100000000000         @ OC2PE set to 1, OC2M set to 110.
.equ TIM2_CCER, 0b0000000000010000          @ CC2E set to 1, CC2P set to 0 (reset value).
.equ TIM2_CR1, 0b0000000000000001           @ CEN set to 1, CMS set to 00 (reset value), DIR to 0 (reset value).
.equ TIM2_EGR, 0b0000000000000001           @ UG set to 1.

.equ RCC_BASE, 0x40021000
.equ RCC_APB1ENR_OFFSET, 0x0000001C

.type initialize_pin, %function
initialize_pin:
    @ Set the GPIOB_AFRL3 to 0b0010 to set the TIM2_CH2 function to
    @ the PORTB3 pin.
    ldr R0, =GPIOB_BASE + GPIOX_AFRL_OFFSET @ R0 stores the GPIOB_AFR register location.
    ldr R1, [R0]                            @ R1 stores the GPIOB_AFR register value.
    
    ldr R2, =0xFFFF0FFF                     @ R2 stores the AND mask.
    and R1, R1, R2
    ldr R2, =0x00002000                     @ R2 stores the OR mask now.
    orr R1, R1, R2

    str R1, [R0]

    bx LR

.type enable_pwm_clock, %function
enable_pwm_clock:
    ldr R0, =RCC_BASE + RCC_APB1ENR_OFFSET  @ R0 stores the RCC_APB1ENR register location.
    ldr R1, [R0]                            @ R1 stores the RCC_APB1ENR register value.

    ldr R2, =0x00000001                     @ R2 stores the OR mask.
    orr R1, R1, R2
    str R1, [R0]

    bx LR

@ Takes no arguments. Returns nothing.
.type tim2_pwm_initialize, %function
tim2_pwm_initialize:
    push {LR}

    bl initialize_pin
    bl enable_pwm_clock

    @ Set prescaler to the TIM2_PRESCALER value.
    ldr R0, =TIM2_BASE + TIM2_PSC_OFFSET
    ldr R1, =TIM2_PRESCALER
    str R1, [R0]

    @ Set auto reload register to the TIM2_ARR value.
    ldr R0, =TIM2_BASE + TIM2_ARR_OFFSET
    ldr R1, =TIM2_ARR
    str R1, [R0]

    @ Set capture/compare register 1 to the TIM2_CCR1 value.
    ldr R0, =TIM2_BASE + TIM2_CCR2_OFFSET
    ldr R1, =TIM2_CCR2
    str R1, [R0]

    @ Set capture/compare mode register 1 to the TIM2_CCMR1 value.
    ldr R0, =TIM2_BASE + TIM2_CCMR1_OFFSET
    ldr R1, =TIM2_CCMR1
    str R1, [R0]

    @ Set capture/compare enable register to the TIM2_CCER value.
    ldr R0, =TIM2_BASE + TIM2_CCER_OFFSET
    ldr R1, =TIM2_CCER
    str R1, [R0]

    @ Set control register 1 to the TIM2_CR1 value.
    ldr R0, =TIM2_BASE + TIM2_CR1_OFFSET
    ldr R1, =TIM2_CR1
    str R1, [R0]

    @ Set event generation register to the TIM2_EGR value.
    ldr R0, =TIM2_BASE + TIM2_EGR_OFFSET
    ldr R1, =TIM2_EGR
    str R1, [R0]

    pop {PC}
