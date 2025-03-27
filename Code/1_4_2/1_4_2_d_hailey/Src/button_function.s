.syntax unified
.thumb

#include "definitions.s"

button_loop:
@ Check if the button (PA0) is pressed
    BL button_press
    CMP R0, #1
    BEQ button_pressed_action

    @ Wait for a short delay to debounce
    BL delay_function

    @ Repeat the loop
    B button_loop


button_pressed_action:
    @ Wait for button release (simple debounce)
    BL button_release

button_press:
	LDR R0, =GPIOA	@ port for the input button
	LDR R1, [R0, IDR]
	TST R1, 0x01
	BEQ not_pressed
	BNE pressed

not_pressed:
	MOV R0, #0 @R0 = 0 meaning button hasnt been pressed
	BX LR

pressed:
	MOV R0, #1 @R0 = 1 meaning button has been pressed
	BX LR

button_release:
    BL delay_function
    BL button_press
    CMP R0, #0 @check if button is still pressed or not
    BNE button_release @if still pressed begin loop again
    BEQ switch_vowels_consonants @once button has been released changes number of vowels to consonants


delay_function:
	MOV R7, #0x03

	@ we continue to subtract one from R6 while the result is not zero,
	@ then return to where the delay_function was called
not_finished_yet:
	SUBS R7, 0x01
	BNE not_finished_yet

	BX LR @ return from function call

