.section .data
.global digits
@ Binary-coded decimals in form
@ 0000000000000000<D3><D2><D1><D0>
digits:
    .word 0x00004500

.section .bss
tim3_tick_phase:
    .word 0x00000000
pause_status:   @ 0 - unpaused, 1 - paused.
    .word 0x00000000

.section .text
.global main
.global tim3_tick
.global toggle_pause

.type decrement_second, %function
decrement_second:
    ldr R0, =digits             @ R0 stores the digits location.
    ldr R1, [R0]                @ R1 stores the digits.
    ldr R2, =0x000000FF         @ R2 stores the AND mask to extract digits that represent seconds (D1:D0).
    
    mov R3, R1                  @ R3 stores only digits that represent seconds.
    and R3, R3, R2
    cmp R3, #0
    beq decrement_second_minute_over
    
    sub R1, R1, #1
    mov R3, R1
    ldr R2, =0x0000000F         @ R2 stores the AND mask to extract the D0 digit only.
    and R3, R3, R2              @ R3 stores the D0 digit now.
    cmp R3, #0x09
    ble decrement_second_skip_subtracting_6_from_secs
    sub R1, #6                  @ F - 9 = 6.
decrement_second_skip_subtracting_6_from_secs:
    str R1, [R0]
    bx LR
decrement_second_minute_over:
    lsr R1, R1, #8              @ R1 stores the minute digits only now.
    sub R1, R1, #1

    mov R3, R1
    ldr R2, =0x0000000F         @ R2 stores the AND mask to extract the first digit only.
    and R3, R3, R2
    cmp R3, #0x09
    ble decrement_second_skip_subtracting_6_from_mins
    sub R1, #6
decrement_second_skip_subtracting_6_from_mins:
    lsl R1, R1, #8
    ldr R2, =0x00000059         @ R2 stores the D1:D0 digits to set.
    orr R1, R1, R2
    str R1, [R0]
    bx LR

.type tim3_tick, %function
tim3_tick:
    push {LR}

    bl tim2_disable

    ldr R0, =tim3_tick_phase
    ldr R1, [R0]
    add R1, R1, #1

    cmp R1, #10
    beq tim3_tick_reset_phase
    str R1, [R0]
    pop {PC}
tim3_tick_reset_phase:
    ldr R1, =0
    str R1, [R0]
    bl tim2_enable
    bl decrement_second

    pop {PC}

.type toggle_pause, %function
toggle_pause:
    push {LR}

    ldr R0, =pause_status       @ R0 stores the pause_status address.
    ldr R1, [R0]                @ R1 stores the pause_status itself.
    cmp R1, #0
    bne toggle_pause_unpause

    ldr R1, =0x00000001
    str R1, [R0]
    bl tim3_disable
    bl tim2_disable

    pop {PC}

toggle_pause_unpause:
    ldr R1, =0x00000000
    str R1, [R0]
    bl tim3_enable

    pop {PC}

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

    bl pause_resume_button_init
     
    bl tim2_initialize
    bl tim3_initialize

loop:
    bl seven_seg_display
    
    b loop
