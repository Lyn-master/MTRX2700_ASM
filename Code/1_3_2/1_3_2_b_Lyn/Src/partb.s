
@ Program description
@ Apply lowercase to all ascii characters inc. Non alphabetical values
@ Compare around the middle postion



.syntax unified
.thumb

.global main

.extern printf




.data

ascii_string: .asciz "@!racecar!@"   @define ascii string

palindrome_mess: .asciz "Is a palindrome\n"
not_palindrome_mess: .asciz "Not a palindrome\n"



.text

main:

LDR R1, = ascii_string     @ Memory address of string
MOV R2, #0                 @ Length of the string


@Find length of ascii string

string_length:

LDRB R3,[R1, R2]   @ Stores in R3, R1 + offset
CMP R3, #0         @ Check end of string
BEQ Palindrome
Add R2, #1         @ R2 stores the length of the string
b string_length


Palindrome:

LSR R4,R2,#1    @ Calculates middle value and store in R4
MOV R5, #0      @ Start counter

Loop:

CMP R5, R4
BGE is_palindrome

@During iteration


SUB R6, R2, R5    @ R6 = R2 -R5
SUB R6, R6, #1    @ R6 = R2 -R5-1

LDRB R7,[R1,R5]    @Beginning of string
LDRB R8,[R1,R6]    @End of string

@Comparing character by character

ORR R7, #0x20       @ Convert foremost entry to lowercase

ORR R8, #0x20       @ Convert furthest entry to lowercase

CMP R7,R8
BNE not_palindrome

ADD R5, #1

b Loop


is_palindrome:

LDR R0, = palindrome_mess
BL printf
BX LR


not_palindrome:

LDR R0, = not_palindrome_mess
BL printf
BX LR        @ Return from main


end_loop:
BX LR        @ Return from main
