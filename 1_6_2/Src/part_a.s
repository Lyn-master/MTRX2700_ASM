.syntax unified
.thumb

#include "definitions.s"

.data

.text
@ define code

@ function entry for part a
delay_function:

	LDR R0, =8 @ with a system clock of 8MHz each microsecond is 8 clock cycles
	MUL R3, R1, R0 @ Converting delay time from microseconds into number of ticks

	@ store the number of times timer needs to count in the Auto-Reload Register
	LDR R0, =TIM2
	STR R3, [R0, #TIM_ARR]

	@ Branch to start the timer
	B enable_timer

@ function to clear any flags, reset timer count and start the timer
enable_timer:

	LDR R0, =TIM2

	@ Reset the counter and start the timer
	LDR R5, =0
    STR R5, [R0, #TIM_CNT]  @ Reset the timer counter to 0
    STR R5, [R0, #TIM_SR]	@ clear the timer Status Register
    LDR R5, =1
    STR R5, [R0, #TIM_CR1]  @ Enable the timer (TIM2)

	B wait_for_delay

@ function to check when the timer overflows and branch to action
wait_for_delay:

	LDR R0, =TIM2
	LDR R6, [R0, #TIM_SR] @ load the Status Register
	CMP R6, #0x1f @ when timer overflows it will set the flags to indicate it has finished one cycle
	BEQ turn_on_led
	B wait_for_delay @ keep checking if unfinished

@ function to blink LEDs to visualise delays
turn_on_led:

	LDR R0, =TIM2

	@ clear the Status Register so it can keep getting flagged for next cycle
	LDR R7, =0
	STR R7, [R0, #TIM_SR]

	@ block to blink LED
	LDR R0, =GPIOE
	LDR R1, [R0, #ODR + 1] @ load current LED pattern
	EOR R1, R1, #0b10101010 @ turn on/off every second LED
	STR R1, [R0, #ODR + 1]

	B wait_for_delay @ keep waiting for next cycle

