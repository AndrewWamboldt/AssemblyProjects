
# Name: Andrew Wamboldt 4/15/2020             i contacted lei for help on this program
###########################################################
#		Program Description
# 
# This program will perform several tasks with arrays. The program will create and read an array, then
# create a copy of the array with values greater than a specified maximum value removed from the array,
# and finally will print both the original and the modified arrays.
# Main will (in this order):
# 1. Call create_array
# 2. Save the base address and length returned by create_array in static variables
# 3. Prompt the user for a maximum value
# 4. Call remove_over_max to remove values over the maximum
# 5. Save the base address and length returned by remove_over_max in static variables
# 6. Call print_array to print the original array
# 7. Call print_array to print the modified array
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
welcome_message:	.asciiz "welcome to program 3"
next_line:			.asciiz "\n"
start_array:		.asciiz "\nMain Array:"
remove_max_prompt:	.asciiz "\nEnter a Maximum value for the array: "

array_pointer:			.word 0 #holds the address of the array
array_size:				.word 0 #holds size of the array
max_array_pointer:
###########################################################
		.text
main:
	li $v0, 4						# print a string
	la $a0, welcome_message
	syscall

	li $v0, 4						# print a new line
	la $a0, next_line
	syscall


	addi $sp, $sp, -4		#allocte one word for $ra
	sw $ra, 0($sp)			# store $ra on stack

	addi $sp, $sp, -12		#allocate words for the arguments Out
							#arguments out array base address, and array length
#####create_Array#######
	jal create_array

	lw $t0, 0($sp)			# returns the array base address now main can use it
	lw $t1, 4($sp)			# same thing with the array size

	addi $sp, $sp 12			# deallocate for these argumements above

	lw $ra, 0($sp)
	addi $sp, $sp, 4		#deallocate for the return address

#######what do with vairables when you come back########

	la $t9, array_pointer
	sw $t0, 0($t9)			#now the arrays base address is stores in a variables

	la $t9, array_size
	sw $t1, 0($t9)			#now the array length is also stored in a vriable

	la $t9, array_pointer
	lw $t0, 0($t9)			#loads the array base address

	la $t9, array_size
	lw $t1, 0($t9)			#loads the array length


	li $v0, 4
	la $a0, start_array
	syscall

#############print_array###############

	addi $sp, $sp, -4		#makes room inthe stack for the return address
	sw $ra, 0($sp)			#now it stores $ra

	addi $sp, $sp, -8		#makes room for the twoarguments to be passed in: address and length
	sw $t0, 0($sp)			#stores the array base address on the stack
	sw $t1, 4($sp)			#stores thearray length on the stack

	jal print_array

	addi $sp, $sp, 8		# deallocate for the arguments passed inot print array

	lw $ra, 0($sp)			#loads the return address form the stack
	addi $sp, $sp, 4		#deallocates for the $ra

	li $v0, 4						# print a new line
	la $a0, next_line
	syscall

##############remove_over_max##################
	
	addi $sp, $sp, -4				#allocate space for the $ra
	sw $ra, 0($sp)					#stores the rretunr address on the stack

	li $v0, 4						# print a string for the max value
	la $a0, remove_max_prompt
	syscall

	
	la $t9, array_pointer		#loads the arrays base address
	lw $t0, 0($t9)				

	la $t9, array_size			#loads the arrays length
	lw $t1, 0($t9)

	addi $sp, $sp, -20				#allocates spae for users input and for the address of the array base and length
	sw $v0, 0($sp)					#also has room for 2 return arguments
	sw $t0, 4($sp)			#stores the array base address on the stack
	sw $t1, 8($sp)			#stores thearray length on the stack

	jal remove_over_max
main_end:
	li $v0, 10		#End Program
	syscall
###########################################################
###########################################################
#		Subprogram Description

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
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
#	$t0 array address
#	$t1 length
#	$t2
#	$t3 
#	$t4 20
#	$t5 10
#	$t6 
#	$t7
#	$t8
#	$t9 temp register
###########################################################
		.data
array_size_prompt_p:    .asciiz "Enter an array size:  "
array_size_prompt_error:    .asciiz "Not between 10 and 20, Enter an array size:  "



###########################################################
		.text
create_array:
	li $t4, 20
	li $t5, 10
	
	
create_array_loop:
	#bgt $v0, $t5, post_create_array_loop

	li $v0, 4              # prompt for array size
    la $a0, array_size_prompt_p
    syscall

	li $v0, 5				#get user input
	syscall

	blt $v0, $t5, create_array_reprompt
	bgt $v0, $t4, create_array_reprompt
	
	
	b post_create_array_loop

create_array_reprompt:
	
	li $v0, 4
	la $a0, array_size_prompt_error
	syscall
	
	b create_array_loop

post_create_array_loop:
	
	addi $sp, $sp, -4		# needs to have space for the reutrn address
	sw $ra, 0($sp)			#stores the retrun address

	addi $sp, $sp, -4		#makes room for space array size
	sw $v0, 0($sp)			#$v0 is the users array size, gets added to the stack

	addi $sp, $sp, -8		#makes room for argurment in and out
	sw $v0, 0($sp)			#stores the arguemnt to pass into and leaves room for the array address

	jal allocate_array

	lw $t0, 4($sp)			# loads the array address into $t0
	addi $sp, $sp, 8		# dealloactes for the arguments in and out in the stock

	lw $t1, 0($sp)			#puts array size back into $t1 after coming back
	addi $sp, $sp, 4		#deallocates the space that was holding length
	
	lw $ra, 0($sp)			#loads return address ($ra)
	addi $sp, $sp, 4		#dealocates for the return address

	
	#####read_array######
	 addi $sp, $sp, -4           # allocate word for $ra
    sw $ra, 0($sp)              # store $ra
    
    addi $sp, $sp, -8           # allocate space for backups
    sw $t0, 0($sp)              # back up array base address
    sw $t1, 4($sp)              # back up array length
    
    addi $sp, $sp, -8           # allocate space for arguments
                                
                            
    sw $t0, 0($sp)              # storess the array base address
    sw $t1, 4($sp)              # stores the array length

	jal read_array

	addi $sp, $sp, 8		#deallocates memoery for the passed in values (address and size)
	
	lw $t0, 0($sp)			#puts aarray address back
	lw $t1, 4($sp)			#same with the array size
	addi $sp, $sp, 8		#deallocate backup elements

	lw $ra, 0($sp)			#now to get back to main loads the return address of Main
	addi $sp, $sp, 4		#de allocate for the $ra



create_array_end:
	sw $t0, 0($sp)			#stroes the array base address in the stack
	sw $t1, 4($sp)			#stores the length in the stack
	
	jr $ra	#return to calling location
###########################################################
###########################################################
#		allocate_array
#
#	Dynamically allocates an array of the given size, 
#	assuming the size passed in is valid.
#
###########################################################
#		Arguments In and Out of subprogram
#
#	$a0	array size
#	$a1
#	$a2
#	$a3
#	$v0	array base address
#	$v1
#	$sp
#	$sp+4
#	$sp+8
#	$sp+12
###########################################################
#		Register Usage
#	$t0 has array size
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

###########################################################
		.text
allocate_array:
	lw $t0, 0($sp)				#loads array size into $t0

	li $v0, 9						# allocate memory space
	sll $a0, $t0, 2					# $a0 = $t0(array size) * 2^2
	syscall 						# $v0 = new array base address

allocate_array_end:
	sw $v0, 4($sp)				# stores the address of allocated array in the stack

	jr $ra							# return to calling location

###########################################################
#       Arguments IN and OUT of subprogram
#   $sp+0   array base address 
#   $sp+4   array length
###########################################################
#       Register Usage
#   $t0  base address array
#   $t1  array length
#   $t2
#   $t3
#   $t4
#   $t5
#   $t6
#   $t7
#   $t8
#   $t9
###########################################################
        .data
read_array_prompt:   .asciiz "Enter an number: "
###########################################################
        .text
read_array:

    lw $t0, 0($sp)              # loads the arrays base address
    lw $t1, 4($sp)              # loads the  arrays length
    
read_array_loop:
    blez $t1, read_array_end    # branch to read_array_end if counter is less than or equal to zero
    
    li $v0, 4                   # prompt for user to enter the number
    la $a0, read_array_prompt
    syscall
    
    li $v0, 5                   # reads integer from the user
    syscall
       
    sw $v0, 0($t0)              # stores the value into the base array address 
    
    addi $t0, $t0, 4            # increment array pointer by 1 index (4)
    addi $t1, $t1, -1           # decrement array size counter so the loop isnt infinite
    
    b read_array_loop           # branch to the loop

read_array_end:
    jr $ra                      # jump back to the main
###########################################################
#       Arguments IN and OUT of subprogram
#   $sp+0   base address 
#   $sp+4   array length
###########################################################
#       Register Usage
#   $t0  base address of array
#   $t1  array length
#   $t2
#   $t3
#   $t4
#   $t5
#   $t6
#   $t7
#   $t8
#   $t9
###########################################################
        .data
print_space:   .asciiz " "
###########################################################
        .text
print_array:
	lw $t0, 0($sp)		#loads the arrays base adddress
	lw $t1, 4($sp)		#loads the array length

print_array_loop:
	blez $t1, print_array_end	#when length = 0 or less then end the loop

	li $v0, 1			#read integer
	lw $a0, 0($t0)		#laods the value at the corrisponidng index in the array
	syscall

	li $v0, 4			#print a " "
	la $a0, print_space
	syscall

	addi $t0, $t0, 4		#have to incrememnt the index of the Array
	addi $t1, $t1, -1		#have to decrease the counter evertime by 1

	b print_array_loop

print_array_end:
    jr $ra                      # jump back to the main
###########################################################
###########################################################
#       Register Usage
#   $t0  max input from user
#   $t1  base adress of array
#   $t2	 array length
#   $t3
#   $t4
#   $t5 counter of how many values to keep
#   $t6
#   $t7
#   $t8
#   $t9
###########################################################
###########################################################
# what i am trying to do here is before the system call i want ocheck the number and not hve it printed to the screen
# then skip that index. therefore i wont have the value appearing on the screen and i am then able to use that length
# as the length needed to allocate the correct amountof memory for it
        .data
print_space:   .asciiz " "
###########################################################
        .text
remove_over_max:
	lw $t0, 0($sp)		#lods the user input maximum value
	lw $t1, 4($sp)		#loads the arrays base adddress
	lw $t2, 8($sp)		#loads the array length

	li $t5, 0
remove_over_max_loop:
	 
	blez $t1, remove_max_allocate	#when length = 0 or less then end the loop

	li $v0, 1			#read integer
	lw $a0, 0($t0)		#loads the value at the corrisponidng index in the array
	bgt $v0, $t0, skip_index		#branch if the read value is greater than the users entered value
	syscall

	li $v0, 4			#print a " "
	la $a0, print_space
	syscall

	addi $t0, $t0, 4		#have to incrememnt the index of the Array
	addi $t1, $t1, -1		#have to decrease the counter evertime by 1
	addi $t5, $t5, 1		#add value to the size of the new array
	b remove_over_max_loop

skip_index:
	addi $t0, $t0, 4		#have to incrememnt the index of the Array
	addi $t1, $t1, -1		#have to decrease the counter evertime by 1

	b remove_over_max_loop
remove_max_allocate:
	addi $sp, $sp, -4           # allocate space for $ra
    sw $ra, 0($sp)              # backup $ra

	addi $sp, $sp, -8           # allocate space for registers to have the array base address and array length
    sw $t1, 0($sp)              # backups for $t1 which is the array base adress
    sw $t5, 4($sp)              # backups for $t5 which is the new array length

    addi $sp, $sp, -12          # allocate space for arguments
    sw $t5, 0($sp)              # pass in array size

    jal allocate_array          # call allocate array

	lw $t3, 4($sp)				#loads the new arrays base address
	addi $sp, $sp, 12			#deallocates memery for the arguemnts passed

	lw $t1, 0($sp)				#restores $t1 (base address)
	lw $t5, 4($sp)				#restores $t5 the new arrays length
	addi $sp, $sp, 8

	lw $ra, 0($sp)				#restores the return address
	addi $sp, $sp				#deallocate for $ra

remove_over_max_end:
    jr $ra                      # jump back to the main
###########################################################