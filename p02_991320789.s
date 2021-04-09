###########################################################
#		Program Description
# Name: Andrew Wamboldt
# Date: 2/25/2020
#The goal of this program is to get used to (a) using different forms of memory, and (b) calling other
#subprograms from main. You will be utilizing both static and dynamic arrays, as well as integer
#variables to a minor extent.
#You will be starting off with a static array of ten prechosen values: { 2, -5, 6, 3, -8, 9, 1, -2, 4, 7 }
#and printing their values to the console. The dynamic array will be the same size as the static
#array (ten integers) but the values will be partially determined by the starting values in the static
#array. You will be prompting the user to input ten numbers ranging from -5 to 20 inclusive; thus
#each input n should be -5 = n = 20. As each valid integer is entered, you should add it with each
#successive element in the static array and store the result in the corresponding dynamic array. A
#more in-depth description of this is described in the overview for the add_array subprogram,
#which is where this process will be taking place.
#Once the dynamic array is full, you should print all the values to the console. Finally, you will call
#a subprogram that will prompt the user to print a value at a particular index in the dynamic array.
#Since the arrays contain ten integers, valid indices are 0-9 where any invalid input should reprompt the user until a valid index has been entered.
#
###########################################################
#		Register Usage
#	$t0
#	$t1
#	$t2
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data
static_array: 		.word  2, -5, 6, 3, -8, 9, 1, -2, 4, 7	#holds values to be increased later
static_array_size:	.word 10				#holds static array size (10)
dynamic_array_pointer: .word 0					#holds the address of the dynamic array
dynamic_array_size: 	.word 0						#holds the dynamic array size
static_array_printout: .asciiz "Static Array: "
dynamic_array_printout:  .asciiz "Dynamic Array: "
empty_line: 		.asciiz 	"\n"

###########################################################
		.text
main:
	

print_static:
	
	li $v0, 4
	la $a0, static_array_printout		#prints out "Static Array"
	syscall
	#la $a2, dynamic_array_pointer	#holds the dynamic base address
	la $t1, static_array		#holds array base address
	move $a0, $t1
	la $t2, static_array_size	#holds the static array size
	lw $a1, 0($t2)
	jal print_array			#jumps and links print_array
	
allocate:

	la $t2, static_array_size	#holds the static array size
	lw $a1, 0($t2)

	jal allocate_array

	la $t3, dynamic_array_pointer
	sw $v0, 0($t3)

read_array:
	la $t1, dynamic_array_pointer
	lw $a0, 0($t1)

	la $t2, static_array		#holds array base address
	move $a1, $t2
	la $t3, static_array_size	#holds the static array size
	lw $a2, 0($t3)

	

	jal add_array	#jumps and links add static array

print_dynamic:
	
	la $t1, dynamic_array_pointer		#holds array base address
	move $a0, $t1
	la $t2, static_array_size	#holds the static array size
	lw $a1, 0($t2)

	jal print_array

search_index:
	move $a1, $t1		#array length
	jal search_array

	
main_end:
	li $v0, 10		#End Program
	syscall
###########################################################

###########################################################
#		Subprogram Description

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0	holds static array pointer
#	$a1	holds static array size pointer
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp
#	$sp+4
#	$sp+8
#	$sp+12
###########################################################
#		Register Usage
#	$t0	static array pointer (base address)
#	$t1	static array size pointer
#	$t2	holds array size temp
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data
enter_number:   .asciiz "Enter a number between -5 and 20: \n"
error_number:	.asciiz "Error, invalid input!"
next_line:		.asciiz "\n"
###########################################################
		.text
add_array:

	move $t1, $a0			#moves dynamic array address
	move $t2, $a1            # move static array address
	move $t3,  $a2		#static array size

	li $v0, 4
	la $a0, next_line
	syscall

add_array_loop:
	blez $t3, add_array_end	#break if $t3 = 0

	li $v0, 4
	la $a0, enter_number		#prompts user for input
	syscall
	
	li $v0, 5					#reads integer
	syscall
	
	bgt $v0, 20, invalid_number
	blt $v0, -5, invalid_number



	#li $v0, 5			#grabs number from static array
	lw $t4, 0($t2)
	
	
	add $t4, $t4, $v0
	
	#addi $v0, $v0, $a0
	sw $t4, 0($t1)
	
	addi $t1, $t1, 4
	addi $t2, $t2, 4	
	addi $t3, $t3, -1		#subtracts 1 from the array counter (10) in $t3
	
	b add_array_loop
invalid_number:
	
	li $v0, 4
	la $a0, error_number
	b add_array_loop

add_array_end:
	
	jr $ra	#return to calling location
###########################################################
###########################################################
#		Subprogram Description

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0 static array base address
#	$a1 array size
#	$a2 dynamic array base address
#	$a3
#	$v0
#	$v1
#	$sp
#	$sp+4
#	$sp+8
#	$sp+12
###########################################################
#		Register Usage
#	$t0	base address for static array
#	$t1
#	$t2
#	$t3     holds the value 10 for array decrement
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9

#######################################################################
		.data

#######################################################################
		.text
allocate_array:
	move $t0, $a1					# move array length to $t0

	li $v0, 9						# setup syscall number 9
	sll $a0, $t0, 2					# $a0 = array length * 2^2
	syscall
									# base address already in $v0
	jr $ra							# return to main
#######################################################################
###########################################################
		.data

space_character: .asciiz " "
###########################################################
		.text
print_array:
	move $t0, $a0			#move static array base address $t0
	move $t1, $a1			#moves array size to $t1
	#li $t3, 10		#adds 10 to $t3 for(i=10; i < array.length; i--)

	

print_array_loop:

	blez $t1, print_array_end	#break if $t1 = 0

	lw $t9, 0($t0)
	
	li $v0, 1			#prompt array element
	move $a0, $t9			# load a value from register $a0
	syscall

	li $v0, 4
	la $a0, space_character		#prints a space between the numbers
	syscall	

	addi $t0, $t0, 4		#adds 4 to array pointer to look at next word (4 bytes)
	addi $t1, $t1, -1		#subtracts 1 from the array counter (10) in $t3
	
	b print_array_loop		#jumps back to the loop
print_array_end:
	
	jr $ra	#return to calling location

###########################################################
		.data
search_array_prompt: .asciiz "Please enter a index "
search_array_error:	.asciiz "invalid please enter a valid array index!!!"
###########################################################
		.text
search_array:
	
	move $t0, $a0			#move dynamic array base address
	move $t1, $a1			#move dynamic array length

	li $v0, 4
	la $a0, search_array prompt
	syscall

	li $v0, 5
	syscall							#reads user input index

	bltz $v0, search_array_invalid

	move $v0, $t6			#moves user input to t9

	sll $t4, $t6, 2		#moves index up by 4
	add $t2, $t2, $t0	#adds to base address
	lw $t3, 0($t2)		#loads into array index

	li $v0, 1
	move $a0, $t9
	syscall


search_array_invalid:

	li $v0, 4
	la $a0, search_array_error		#prints error when an invaild index is entered
	syscall
	b search_array

search_array_end:

	jr $ra			#returns to where it was called