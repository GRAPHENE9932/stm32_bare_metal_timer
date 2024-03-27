.section .bss
@ Binary-coded decimals in form
@ 0000000000000000<D3><D2><D1><D0>
digits:
    .word 0x00000000

.section .text
.global main

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

.type main, %function
main:
    ldr R0, =digits
    ldr R1, =0x00001234
    str R1, [R0]

    bl enable_io_porta_clock
    bl enable_io_portb_clock
    
    ldr R0, =3                  @ Port number.
    ldr R1, =0b10               @ Alternate function mode.
    bl set_gpiob_moder

    bl enable_shift_out_pins

    ldr R0, =digits         @ Digits location.
    bl seven_seg_set_digits_address
     
    bl tim2_pwm_initialize

loop:
    bl seven_seg_display
    
    b loop
