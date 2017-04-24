# convert.s - Converting lower to upper case
.section .data
Message: .ascii "Please type in a statement to be converted: "
	 .equ MsgLen, .-Message
Buffer: .fill 32
	.equ BufLen, .-Buffer
Array:	.asciz "alfa    ","bravo   ","charlie ","delta   ","echo    ","foxtrot ","golf    ","hotel   ","india   ","juliett ","kilo    ","lima    ","mike    ","november","oscar   ","papa    ","quebec  ","romeo   ","sierra  ","tango   ","uniform ","victor  ","whiskey ","x-ray   ","yankee  ","zulu    "
	.equ ArrayLen, (.-Array)/26
NewLine: .ascii "\n"
Space: .ascii " "

.section .text
.globl _start

_start:
  # print out intro question
  movl $4,%eax
  movl $1,%ebx
  movl $Message,%ecx
  movl $MsgLen,%edx
  int $0x80

  # get input
  movl $3,%eax
  movl $1,%ebx
  movl $Buffer,%ecx
  movl $BufLen,%edx
  int $0x80

  leal Buffer, %esi  # loads string1(memory address) into esi
  leal Buffer, %edi    # also points edi to string1
  cld		     # clears DF

while:
  lodsb		     # uses the memory address loaded in esi (string1)
		     # throws first byte into al
  cmpb $0, %al       # check for null
    je end
  cmpb $' ', %al
    je newline
  cmpb $'A', %al     # lower limit
    jl skip
  cmpb $91, %al      # char after Z
    jl changeCase    # char is upper, changing to lower for simplicity
  cmpb $'a', %al     # 
    jl skip	     # char is between cases, not valid
  cmpb $'z', %al
    jg skip	     # if greater then its not a letter

valid:               # case changed to lower, char is valid
  movb %al,%bl       # set up counter for loop on bl (al and cl are needed)
  subb $0x61,%bl     # get a number from 0-25 based on letter
  movl $Array, %ecx
  jmp forloop

#print military word
trim:
  # backup registers
  pushw %ax
  pushl %esi
  pushl %edi
  
  # step through military word (looking to remove excess spaces)
  movl $0, %edx
  leal (%ecx), %esi   # use ecx since it was incremented to the correct word
  movl %esi, %edi

  whileMil:
  lodsb

  cmpb $0, %al
  je print
  cmpb $' ', %al
  je print
  stosb
  addl $1, %edx      # add one to the buffer
  jmp whileMil
  
print:
  # print word using buffer just calculated
  movl $4,%eax
  movl $1,%ebx
  int  $0x80

  # print space
  movl $4, %eax
  movl $1, %ebx
  movl $Space, %ecx
  movl $1, %edx
  int $0x80

  # restore registers
  popl %edi
  popl %esi
  popw %ax

skip:
  stosb		     # pulls al and throws it into edi (also string1)
		     # both esi and edi are now incremented
  jmp while

newline:
  pushw %ax	     # backup al before using eax
  movl $4,%eax
  movl $1,%ebx
  movl $NewLine,%ecx
  movl $1,%edx
  int $0x80
  popw %ax
  jmp skip         # else move onto the next word

forloop:
  cmpb $0, %bl
  je trim
  addl $ArrayLen,%ecx
  subb $1, %bl
  jmp forloop

end:
  movl $4,%eax	     # print
  movl $1,%ebx	     # stdout
  movl $NewLine,%ecx
  movl $1,%edx
  int $0x80

  movl $1,%eax       # exit
  movl $0,%ebx
  int $0x80

changeCase:
  addb $0x20, %al
  jmp valid
