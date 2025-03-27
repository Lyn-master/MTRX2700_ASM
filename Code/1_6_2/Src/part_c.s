.syntax unified
.thumb

#include "part_b.s"

.data

.text
@ define code


@ entry function for part c
delay:

	LDR R0, =TIM2

	@ enable ARPE
	LDR R1, [R0]
	ORR R1, R1, #0b10000000 @ set bit 7 (ARPE) to 1
	STR R1, [R0]

	@ set prescaler and start timer to trigger prescaler
	LDR R1, =7999 @ we want a tick of 1ms or 1kHz = 8000kHz/ (7999+1)
	STR R1, [R0, #TIM_PSC] @ set the prescaler register
	LDR R1, =1
	STR R1, [R0, #TIM_CR1]

	BL trigger_prescaler

	@ stop timer
	LDR R0, =TIM2
	LDR R1, =0
	STR R1, [R0, #TIM_CR1]

	@ set the Auto-Reload Register to our delay value
	LDR R3, =500 @ 500 x 1ms = 500ms delay
	STR R3, [R0, #TIM_ARR]

	B enable_timer
