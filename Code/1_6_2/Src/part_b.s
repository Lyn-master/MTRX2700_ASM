.syntax unified
.thumb

#include "initialise.s"
#include "part_a.s"

.data

.text
@ define code

@ the next three function blocks are for calculations only
microsecond_delay:

	@ store a value for the prescaler
	LDR R0, =TIM2	@ load the base address for the timer
	LDR R1, =7 @ for 1 microsecond ticks we need clock at 1MHz so 8MHz/(1+7) = 1MHz
	STR R1, [R0, #TIM_PSC] @ set the prescaler register

	BL trigger_prescaler

	LDR R3, =1 @ we want to flag after 1 tick = 1 microsecond
	STR R3, [R0, #TIM_ARR]

	B enable_timer

second_delay:

	@ store a value for the prescaler
	LDR R0, =TIM2	@ load the base address for the timer
	LDR R1, =7999 @ modifying clock to 8MHz / (1+7999) = 1kHz
	STR R1, [R0, #TIM_PSC] @ set the prescaler register

	BL trigger_prescaler

	LDR R3, =1000 @ we want to flag after 1000 ticks = 1000 x 1 ms = 1s
	STR R3, [R0, #TIM_ARR]

	B enable_timer

hour_delay:

	@ store a value for the prescaler
	LDR R0, =TIM2	@ load the base address for the timer
	LDR R1, =7999 @ for 1 ms ticks we need clock at 1kHz so 8MHz/(1+7999) = 1kHz
	STR R1, [R0, #TIM_PSC] @ set the prescaler register

	BL trigger_prescaler

	LDR R3, =3600000 @ 60min x 60s x 1000 = 3600000ms
	STR R3, [R0, #TIM_ARR]

	B enable_timer


@ function entry for the 0.1ms delay required in part b
millisecond_delay:

	LDR R0, =TIM2
	LDR R1, =799 @ we want a tick of 0.1ms = 100 microsecond so the clock rate should be 10kHz
	STR R1, [R0, #TIM_PSC] @ set the prescaler

	@ start the timer to trigger prescaler
	LDR R1, =1
	STR R1, [R0, #TIM_CR1]

	BL trigger_prescaler

	@ stop the timer
	LDR R0, =TIM2
	LDR R1, =0
	STR R1, [R0, #TIM_CR1]

	@ set the Auto-Reload Register so we can better visualise the delay
	LDR R3, =10000 @ 10000 counts for 1s delays
	STR R3, [R0, #TIM_ARR]

	B enable_timer
