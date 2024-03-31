.section .data
@ Binary-coded decimals in form
@ 0000000000000000<D3><D2><D1><D0>
digits:
    .word 0x00009012

.section .text
.global main
.global tim3_tick

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
