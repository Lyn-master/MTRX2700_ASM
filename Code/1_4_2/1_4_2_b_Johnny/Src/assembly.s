.syntax unified
.thumb

.global main

#include "definitions.s"
#include "initialise.s"

.data
@ Define variables
led_count: .byte 0b00000000 @ Initialise bitmask for LED state

.text

@ this is the entry function called from the startup file
main:
	MOV R5, #0 @ Register 5 is our flag for when all LEDs are on

	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	BL enable_timer2_clock

	BL initialise_timer

@ Main program loop
program_loop:

	@ Check if button is pressed
    BL button_press
    CMP R0, #1
    BEQ button_pressed_action

    @ Wait for a short delay to debounce
    BL delay_function

    @ Repeat the loop
    B program_loop

@ Check if button is pressed
button_press:
	LDR R0, =GPIOA	@ port for the input button
	LDR R1, [R0, #IDR]
	TST R1, 0x01
	BEQ not_pressed
	BNE pressed

	not_pressed:
		MOV R0, #0
		BX LR

	pressed:
		MOV R0, #1
		BX LR

@ Perform actions if button is pressed
button_pressed_action:

    @ Check if all LEDs are on
    BL led_check

    @ Wait for button release (simple debounce)
    BL button_release

    @ Continue looping
    B program_loop

@ If all LEDs are on then turn off all LEDs
led_check:
	CMP R5, #0
	BEQ increment_leds @ If not all LEDs are on then we want to light up one more LED
	BNE reset

@ Reset all bits to 0
reset:
	LDR R0, =led_count
	LDR R1, [R0]
	MOV R1, #0
	MOV R5, #0 @ reset flag to 0
	B light_up_leds @ update LED states

@ Increment the LED count
increment_leds:
    LDR R0, =led_count @ Load address of led_count variable
    LDR R1, [R0] @ Load the current LED count
    LSL R1, R1, #1 @ Left shift all bits to the left 1 bit
    ADD R1, R1, #1 @ Increment the LED count
    CMP R1, #0xFF @ Check if all LEDs are lit
    BEQ led_full @ If full then update flag
    B light_up_leds

@ Function to wait for button to release (debounce)
button_release:
    BL delay_function @ Introduce short delay
    BL button_press @ Check if button is unpressed
    CMP R0, #0
    BNE button_release @ Loop until unpressed
    BEQ program_loop

@ Update flag if all LEDs are full
led_full:
	MOV R5, #1
	B light_up_leds

@ Update LED output state
light_up_leds:
    STR R1, [R0] @ Store the updated LED count
    LDR R0, =GPIOE @ Load the address of GPIOE
    LDR R2, =led_count @ Load address of led_count
    LDR R1, [R2] @ Load the current LED count
    STR R1, [R0, #ODR + 1] @ Store the value in the ODR register to turn LEDs on/off
    BX LR @ return to function call

@ Simple delay function
@delay_function:
@	MOV R6, #0x03

	@ we continue to subtract one from R6 while the result is not zero,
	@ then return to where the delay_function was called
@not_finished_yet:
@	SUBS R6, 0x01
@	BNE not_finished_yet
@
@	BX LR @ return from function call


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
