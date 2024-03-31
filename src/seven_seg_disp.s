.section .data
/*
 0---
5|   |1
 6---
4|   |2
 3---
*/
@ Bits are reversed, as the shift_out function outputs bits reversed.
seven_seg_display_leds:
.byte 0b11111100    @ 0
.byte 0b01100000    @ 1
.byte 0b11011010    @ 2
.byte 0b11110010    @ 3
.byte 0b01100110    @ 4
.byte 0b10110110    @ 5
.byte 0b10111110    @ 6
.byte 0b11100000    @ 7
.byte 0b11111110    @ 8
.byte 0b11110110    @ 9
.byte 0b11101110    @ A
.byte 0b00111110    @ B
.byte 0b10011100    @ C
.byte 0b01111010    @ D
.byte 0b10011110    @ E
.byte 0b10001110    @ F

.section .bss
digits_address:
    .word 0x00000000

.section .text
.global seven_seg_set_digits_address
.global seven_seg_display

@ Arguments:
@ R0 - address to the binary-coded decimal in form
@ 0000000000000000<D3><D2><D1><D0>
@ Where Dn - is the nth binary-coded decimal digit.
@ Returns nothing.
.type seven_seg_set_digits_address, %function
seven_seg_set_digits_address:
    ldr R1, =digits_address @ R1 stores the digits address address.
    str R0, [R1]

    bx LR

@ Accepts no arguments. Returns nothing.
.type seven_seg_display, %function
seven_seg_display:
    push {LR}

    ldr R0, =seven_seg_display_leds @ R0 stores address to the digit LEDs dictionary.
    ldr R1, =digits_address         @ R1 stores the digits.
    ldr R1, [R1]
    ldr R1, [R1]
    ldr R4, =0                      @ R4 is the loop counter.
    ldr R5, =0x00001000             @ R5 stores the inverted AND mask of digit selector bits.

seven_seg_display_loop:
    mov R3, R1
    ldr R2, =0x0000000F             @ R2 just stores 0x0000000F temporarily here.
    and R3, R3, R2                  @ R3 stores just a one digit.

    push {R0, R1, R4, R5}
    
    ldrb R0, [R0, R3]               @ The bits to shift out.
    cmp R4, #2
    bne seven_seg_display_loop_skip_dot
    ldr R6, =1
    orr R0, R0, R6
seven_seg_display_loop_skip_dot:
    ldr R1, =0x0000F000
    orr R0, R0, R1
    mvn R1, R5
    and R0, R0, R1
    ldr R1, =16                     @ Amount of bits to shift out.
    bl shift_out_bits

    pop {R5, R4, R1, R0}

    lsr R1, R1, #4
    lsl R5, R5, #1
    add R4, R4, #1
    cmp R4, #4
    bne seven_seg_display_loop

    pop {PC}
