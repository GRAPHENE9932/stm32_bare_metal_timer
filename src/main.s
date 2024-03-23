.section .text
.global main

.equ RCC_BASE, 0x40021000
.equ RCC_AHBENR_OFFSET, 0x00000014
.equ RCC_AHBENR_IOPAEN_BIT, 17

.equ GPIOA_BASE, 0x48000000
.equ GPIOA_MODER_OFFSET, 0x00000000
.equ GPIOX_ODR_OFFSET, 0x00000014

@ Accepts no arguments. Returns nothing.
.type enable_io_porta_clock, %function
enable_io_porta_clock:
    ldr R0, =RCC_BASE + RCC_AHBENR_OFFSET@ R0 stores the word location.
    ldr R1, =1
    lsl R1, R1, #RCC_AHBENR_IOPAEN_BIT  @ R1 stores the bit.
    ldr R2, [R0]                        @ R2 stores the value.
    orr R2, R2, R1
    str R2, [R0]

    bx LR

@ Arguments:
@ R0 - port number.
@ R1 - mode (0b00, 0b01, 0b10 or 0b11)
@ 0b00 - Input mode (reset state).
@ 0b01 - General purpose output mode.
@ 0b10 - Alternate function mode.
@ 0b11 - Analog mode.
@ Returns nothing.
.type set_gpioa_moder, %function
set_gpioa_moder:
    ldr R2, =GPIOA_BASE + GPIOA_MODER_OFFSET@ R2 stores the word location.
    lsl R0, R0, #1                          @ Multiplying R0 by 2.
    lsl R1, R1, R0                          @ R1 stores the bits to orr with.
    ldr R4, =0xFFFFFFFC
    ldr R3, [R2]
    and R3, R3, R4
    orr R3, R3, R1
    str R3, [R2]

    bx LR

@ Arguments:
@ R0 - port number.
@ Returns nothing.
.type write_high_gpio_odr, %function
write_high_gpio_odr:
    ldr R1, =GPIOA_BASE + GPIOX_ODR_OFFSET  @ R1 stores the word location.
    ldr R2, =1                              @ R2 contains the bit.
    lsl R2, R2, R0
    ldr R3, [R1]                            @ R3 stores the word.
    orr R3, R3, R2
    str R3, [R1]

    bx LR

@ Arguments:
@ R0 - port number.
@ Returns nothing.
.type write_low_gpio_odr, %function
write_low_gpio_odr:
    ldr R1, =GPIOA_BASE + GPIOX_ODR_OFFSET  @ R1 stores the word location.
    ldr R2, =0xFFFFFFFE                     @ R2 contains the bit.
    lsl R2, R2, R0
    ldr R3, [R1]                            @ R3 stores the word.
    and R3, R3, R2
    str R3, [R1]

    bx LR

@ Accepts no arguments. Returns nothing.
@ Just wastes 4000001 cycles.
.type delay_for_4m_cycles, %function
delay_for_4m_cycles:                @ 4 cycles to call.
    ldr R0, =0                      @ 2 cycles.
    ldr R1, =799998                 @ 2 cycles.
delay_for_4m_cycles_loop:
    add R0, R0, #1                  @ 1 cycle.
    cmp R0, R1                      @ 1 cycle.
    blo delay_for_4m_cycles_loop    @ 3 cycle if taken, 1 if not.

    bx LR                           @ 3 cycles.

.type main, %function
main:
    bl enable_io_porta_clock

    ldr R0, =12         @ Port number.
    ldr R1, =0b01       @ Output mode.
    bl set_gpioa_moder

loop:
    ldr R0, =12         @ Port number.
    bl write_high_gpio_odr

    bl delay_for_4m_cycles

    ldr R0, =12         @ Port number.
    bl write_low_gpio_odr

    bl delay_for_4m_cycles

    b loop
