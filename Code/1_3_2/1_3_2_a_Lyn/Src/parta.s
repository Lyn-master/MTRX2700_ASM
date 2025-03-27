/*
Program description

1. Non alphabetical characters are left unchanged

(State of R2)

2. If character is uppercase and R2 = 1, leave it as uppercase;
   If character is uppercase and R2  = 0, change to lowercase

3. If character is lowercase and R2 = 1, change to uppercase;
   If character is lowercase and R2  = 0,leave it as lowercase


*/



.syntax unified
.thumb
.global main


.data

ascii_string: .asciz ":)Hi[}"

.text

main:

LDR R1, = ascii_string    @Memory address of string
MOV R3, #0                @ offset

@Define R2

MOV R2, #1

string_loop:

LDRB R4, [R1, R3]          @ Load into R4 character from string
CMP R4, #0                 @Check end of string
BEQ end_loop


@Pass this point R4 hasn't reached end of string

@ Check if in alphabet range A = 65 B = 90 a = 97 b = 122


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

CMP R2, #0          @ Convert to lower case
BNE next_letter
ADD R4, 32          @ Add 32 to get lower case equivalent
STRB R4, [R1,R3]    @ Store modification in current address R1
b next_letter

lower_case:

CMP R2, #1          @ Convert to upper case
BNE next_letter
SUB R4,32           @ Subtract 32 to get upper case equivalent
STRB R4, [R1,R3]    @ Store modification in current address R1


next_letter:

@Increment and restart loop
ADD R3, #1
b string_loop


end_loop:
BX LR @ Return from main


