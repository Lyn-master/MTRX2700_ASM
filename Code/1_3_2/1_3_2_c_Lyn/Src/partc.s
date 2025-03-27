
.syntax unified

.thumb

.global main


.data

ascii_string:.asciz "@ab!xZ"  @Define ascii string




.text

main:

LDR R1, = ascii_string       @ Memory address of string

MOV R2, #3                   @ Value for right shift

Mov R3, #0                   @ Offset for incrementation



string_loop:

LDRB R4, [R1, R3]          @ Store each character into register R4
CMP R4, #0                 @ Check end of string
BEQ end_loop



@ Check if in alphabet range A = 65 Z = 90 a = 97 z = 122

CMP R4, #65
BLT next_letter

CMP R4, #122
BGT next_letter

@ Upper case range 65<= # < 91
CMP R4, #91
BLT upper_case

@ Invalid case range 91 <= # <= 96

CMP R4, #96
BLE next_letter

@ Lower case range 97 <= # <= 122
CMP R4, #97
BGE lower_case


upper_case:

ADD R4, R2              @ Increase ascii character by 3 spaces  
CMP R4, #90             @ Compare with upper limit Z
BLE update_str
SUB R4, R4, #26         @ Loop back from A
B update_str

lower_case:
ADD R4, R2              @ Increase ascii character by 3 spaces 
CMP R4, #122
BLE update_str          @ Compare with upper limit z
SUB R4, R4, #26         @ Loop back from a
B update_str



update_str:
STRB R4, [R1,R3]  @store in current place of string, R1




next_letter:

@Increment and restart loop

ADD R3, #1
b string_loop



end_loop:

BX LR   @ Return from main






