.syntax unified
.thumb

.global main

#include "definitions.s"
#include "initialise.s"

.data
@ Define variables

.text

@ this is the entry function called from the startup file
main:
	MOV R5, #0

	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	BL enable_timer2_clock

	BL initialise_timer

@part a: set LEDs to the bit mask pattern provided
set_LED_pattern:

	LDR R1, =0b00000000 @bit mask for pattern of LEDs
	LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
  	STRB R1, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15), hence lighting the LEDs


@parts b and c: light up one additional LED with each button press nttil all 8 are lit then decrease one LED with each button press
program_loop:
@ Check if the button (PA0) is pressed
    BL button_press
    CMP R0, #1 @check state of button from button_press
    BEQ button_pressed_action

    @ Wait for a short delay to debounce
    BL delay_function

    @ Repeat the loop
    B program_loop

@ function to perform actions once the button is pressed
button_pressed_action:
    @ Increment LED count
    BL led_check

    @ Wait for button release (simple debounce)
    BL button_release

    @ Continue looping
    B program_loop

@ function to check status of button and update flags based on the current state
button_press:
	LDR R0, =GPIOA	@ port for the input button
	LDR R1, [R0, #IDR] @load state of button to R1
	TST R1, 0x01 @check if button pressed or not
	BEQ not_pressed
	BNE pressed

	BX LR

	@ functions to update the button status flag
	not_pressed:
		MOV R0, #0
		BX LR

	pressed:
		MOV R0, #1
		BX LR

@ function to debounce the button and register held down button as one button press
button_release:
    BL delay_function
    BL button_press 		@check button has been released yet
    CMP R0, #0
    BNE button_release
    BEQ program_loop

@ function to determine whether number of LEDs lit should increase or decrease
led_check:
	CMP R5, #0 				@check if currently increasing or decreasing LEDs
	BEQ increment_leds
	BNE reduce_leds

@ Increment the LED count
increment_leds:
    LDR R0, =led_count      @ Load address of led_count variable
    LDR R1, [R0]            @ Load the current LED count
    LSL R1, R1, #1
    ADD R1, R1, #1          @ Increment the LED count
    CMP R1, #0xFF           @ Maximum 8 LEDs (PE8 to PE15)
    BEQ led_full
    B light_up_leds
    @MOV R1, #0              @ Reset if more than 8 LEDs

@ updates flag for indicating it should start descreasing number of LEDs lit
led_full:
	MOV R5, #1 				@change to now decreasing LEDs
	B light_up_leds

@ function to dim one more LED
reduce_leds:
	LDR R0, =led_count 		@ Load address of led_count variable
    LDR R1, [R0]            @ Load the current LED count
	LSR R1, R1, #1
	CMP R1, #0
	BEQ led_empty @ update flag to indicate it should increase number of LEDs lit next time
	B light_up_leds

@ updates flag for indicating it should start increasing number of LEDs lit
led_empty:
	MOV R5, #0
	B light_up_leds

@ function to light up one more LED
light_up_leds:
    STR R1, [R0]            @ Store the updated LED count
    @ Control LEDs based on the count (PE8 to PE15)
    LDR R0, =GPIOE          @ Load the address of GPIOE
    LDR R2, =led_count      @ Load address of led_count
    LDR R1, [R2]            @ Load the current LED count
    STR R1, [R0, #ODR + 1]      @ Store the value in the ODR register to turn LEDs on/off
    BX LR


@ timer based delay function for 1ms
delay_function:
	LDR R0, =TIM2

	@ start the timer
	LDR R1, =1
	STR R1, [R0, #TIM_CR1]

	@ check if 1ms has passed
	LDR R6, [R0, #TIM_SR] @ load the Status Register
	CMP R6, #0x1f @ when timer overflows it will set the flags to indicate it has finished one cycle
	BNE delay_function @ keep checking if unfinished

	@ stop the timer and reset all flags and counters
	LDR R1, =0
	STR R1, [R0, #TIM_CR1]
	STR R1, [R0, #TIM_CNT]
	STR R1, [R0, #TIM_SR]
	BX LR


.section .bss
led_count: .skip 8          @ Reserve 8 bytes for LED count
