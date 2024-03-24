.section .text
.global main

.equ RCC_BASE, 0x40021000
.equ RCC_AHBENR_OFFSET, 0x00000014
.equ RCC_AHBENR_IOPAEN_BIT, 17

.equ GPIOA_BASE, 0x48000000
.equ GPIOA_MODER_OFFSET, 0x00000000
.equ GPIOX_ODR_OFFSET, 0x00000014

.equ SER_PORT_NUMBER, 10
.equ SRCLK_PORT_NUMBER, 9
.equ RCLK_PORT_NUMBER, 12

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
@ R1 - what to write (either 0 or 1).
@ Returns nothing. Modifies the R0-R4 registers.
@ Takes 20 cycles in total.
.type write_to_gpioa_odr, %function
write_to_gpioa_odr:                         @ 4 cycles to call.
    ldr R2, =GPIOA_BASE + GPIOX_ODR_OFFSET  @ 2 cycles; R2 stores the ODR location.
    lsl R1, R1, R0                          @ 1 cycle; R1 stores the OR mask now.
    ldr R3, =1                              @ 2 cycles; R3 stores the AND mask.
    lsl R3, R3, R0                          @ 1 cycle.
    mvn R3, R3                              @ 1 cycle.
    
    ldr R4, [R2]                            @ 2 cycles; R4 contains the ODR.
    and R4, R4, R3                          @ 1 cycle.
    orr R4, R4, R1                          @ 1 cycle.
    str R4, [R2]                            @ 2 cycles.

    bx LR                                   @ 3 cycles.

@ Accepts no arguments. Returns nothing.
@ Just wastes 4000000 cycles.
.type delay_for_4m_cycles, %function
delay_for_4m_cycles:                @ 4 cycles to call.
    ldr R0, =0                      @ 2 cycles.
    ldr R1, =799998                 @ 2 cycles.
delay_for_4m_cycles_loop:
    add R0, R0, #1                  @ 1 cycle.
    cmp R0, R1                      @ 1 cycle.
    blo delay_for_4m_cycles_loop    @ 3 cycle if taken, 1 if not.

    nop                             @ 1 cycle.
    bx LR                           @ 3 cycles.

@ Arguments:
@ R0 - register that contains the bits.
@ R1 - how many bits to shift out (8, 16, 24 and 32 are allowed).
.type shift_out_bits, %function
shift_out_bits:
    push {LR}

    mov R5, R0                  @ Move our arguments to R5 and R6 respectively, as write_to_gpioa_odr will modify the R0-R4 registers.
    mov R6, R1

    ldr R0, =RCLK_PORT_NUMBER   @ Port number.
    ldr R1, =0                  @ What to write.
    bl write_to_gpioa_odr

    ldr R2, =0
    mov R8, R2                  @ R8 is the loop counter.
shift_out_bits_loop:

    ldr R0, =SER_PORT_NUMBER    @ Port number.
    ldr R1, =0                  @ What to write.
    bl write_to_gpioa_odr

    ldr R0, =SRCLK_PORT_NUMBER  @ Port number.
    ldr R1, =0                  @ What to write.
    bl write_to_gpioa_odr

    ldr R0, =SER_PORT_NUMBER    @ Port number.
    mov R1, R5                  @ What to write.
    ldr R2, =1
    and R1, R1, R2
    bl write_to_gpioa_odr

    ldr R0, =SRCLK_PORT_NUMBER  @ Port number.
    ldr R1, =1                  @ What to write.
    bl write_to_gpioa_odr

    lsr R5, R5, #1
    mov R1, R8
    add R1, R1, #1
    mov R8, R1

    cmp R8, R6
    blo shift_out_bits_loop
@ End of the shift_out_bits_loop

    ldr R0, =SRCLK_PORT_NUMBER  @ Port number.
    ldr R1, =1                  @ What to write.
    bl write_to_gpioa_odr

    ldr R0, =RCLK_PORT_NUMBER   @ Port number.
    ldr R1, =1                  @ What to write.
    bl write_to_gpioa_odr

    ldr R0, =SER_PORT_NUMBER    @ Port number.
    ldr R1, =0                  @ What to write.
    bl write_to_gpioa_odr

    ldr R0, =SRCLK_PORT_NUMBER  @ Port number.
    ldr R1, =0                  @ What to write.
    bl write_to_gpioa_odr

    ldr R0, =RCLK_PORT_NUMBER   @ Port number.
    ldr R1, =0                  @ What to write.
    bl write_to_gpioa_odr

    pop {PC}

.type main, %function
main:
    bl enable_io_porta_clock

    ldr R0, =SER_PORT_NUMBER    @ Port number.
    ldr R1, =0b01               @ Output mode.
    bl set_gpioa_moder

    ldr R0, =SRCLK_PORT_NUMBER  @ Port number.
    ldr R1, =0b01               @ Output mode.
    bl set_gpioa_moder

    ldr R0, =RCLK_PORT_NUMBER   @ Port number.
    ldr R1, =0b01               @ Output mode.
    bl set_gpioa_moder

    ldr R0, =0b00000000000000001101111111011010  @ Bits.
    ldr R1, =16             @ How many bits to shift out.
    bl shift_out_bits

    b main
