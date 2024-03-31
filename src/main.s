.section .data
@ Binary-coded decimals in form
@ 0000000000000000<D3><D2><D1><D0>
digits:
    .word 0x00009012

.section .text
.global main
.global tim3_tick

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

.type tim3_tick, %function
tim3_tick:
    ldr R0, =digits
    ldr R1, [R0]
    add R1, R1, #1
    str R1, [R0]

    bx LR

.type main, %function
main:
    bl enable_io_porta_clock
    bl enable_io_portb_clock
    
    ldr R0, =3                  @ Port number.
    ldr R1, =0b10               @ Alternate function mode.
    bl set_gpiob_moder

    bl enable_shift_out_pins

    ldr R0, =digits         @ Digits location.
    bl seven_seg_set_digits_address
     
    bl tim2_initialize
    bl tim3_initialize

    bl tim2_enable

loop:
    bl seven_seg_display
    
    b loop
