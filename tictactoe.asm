.data
prompt1: .asciiz "\n"
prompt2: .asciiz "Enter row (0,1,2): \n"
prompt3: .asciiz "Enter column (0,1,2): \n"
prompt4: .asciiz "Computer: \n"
prompt5: .asciiz "Winner! \n"
prompt6: .asciiz "Input 0 to go first or 1 for second"
prompt7: .asciiz "Draw"
.text

li $a2, 0 # Counter for moves played
li  $t1,3
li  $t2,3
mul $a0, $t1, $t2  # 2x2 array

li  $v0, 9
syscall
move $s0,$v0

li $t3, 0 

outerFillB:   # Loop for filling array with empty space marked by '-'
 bge $t3, $t1, exitOuterF 
 li $t4, 0
innerFillB:
 bge $t4, $t2, exitInnerF
 
 sll $t6, $t3, 2 #Row major order
 sll $t7, $t4, 2
 mul $t5, $t6, $t2
 add $t5, $t5, $t7 
 add $t5, $s0, $t5
 
 li $v1, '-'

 sw $v1, 0($t5) #storing '-'
 
 addi $t4, $t4, 1
 
 b innerFillB
exitInnerF:
addi $t3, $t3, 1
 b outerFillB
exitOuterF: #end of fill loop

jal PrintB

GameLoop: # Main loops in here
li $v0, 4
la $a0, prompt6 # Ask if the player wants to go first or second and accepts input
syscall

li $v0, 5
syscall
move $t3, $v0

beq $t3, 1, playerSecond #Branch if second

playerFirst: #Begin main loop

jal playerTurn
sw $v1, 0($t5)
add $a2, $a2, 1

jal PrintB
jal WinConditions

li $v0, 4
la $a0, prompt4
syscall

jal Random
sw $v1, 0($t5)
add $a2, $a2, 1

jal PrintB
jal WinConditions

b playerFirst
exitPlayerFirst: #End main loop


playerSecond: #Begin main loop
li $v0, 4
la $a0, prompt4
syscall

jal Random
sw $v1, 0($t5)
add $a2, $a2, 1

jal PrintB
jal WinConditions

jal playerTurn
sw $v1, 0($t5)
add $a2, $a2, 1

jal PrintB
jal WinConditions

b playerSecond
exitPlayerSecond: #End main loop


PrintB: #Print function
li $t3, 0
outerPrintB:
 bge $t3, $t1, exitOuterB
 li $t4, 0
innerPrintB: #Row major print
 bge $t4, $t2, exitInnerB
 
 sll $t6, $t3, 2
 sll $t7, $t4, 2
 mul $t5, $t6, $t2
 add $t5, $t5, $t7
 add $t5, $s0, $t5

 lw $v1, 0($t5)
 
 li $v0, 11
 la $a0, ($v1)# Load value at [x][y] and print
 syscall

 addi $t4, $t4, 1
 
 b innerPrintB
exitInnerB:

li $v0, 4
la $a0, prompt1
syscall

addi $t3, $t3, 1
 b outerPrintB
 
exitOuterB: 
jr $ra # Return for print


WinConditions: #Checks if either player has won

li $t3, 0
outerRC: # Row checks
 bge $t3, $t1, checkColumns # Move to column check if nothing found
 li $t4, 0

 sll $t6, $t3, 2
 sll $t7, $t4, 2
 mul $t5, $t6, $t2
 add $t5, $t5, $t7
 add $t5, $s0, $t5
 lw $t8, 0($t5)
 addi $t4, $t4, 1

 sll $t6, $t3, 2
 sll $t7, $t4, 2
 mul $t5, $t6, $t2
 add $t5, $t5, $t7
 add $t5, $s0, $t5
 lw $t9, 0($t5)
 addi $t4, $t4, 1
 
 sll $t6, $t3, 2
 sll $t7, $t4, 2
 mul $t5, $t6, $t2
 add $t5, $t5, $t7
 add $t5, $s0, $t5
 lw $t7, 0($t5)
 addi $t4, $t4, 1
 
 addi $t3, $t3, 1
 
 beq $t8, '-', outerRC #Ensures no 3 in a row of '-' blank character
 seq $t0,$t7,$t8
 seq $t9,$t8,$t9
 beq $t0, $zero, outerRC
 beq $t0,$t9, Win
 
 b outerRC

checkColumns: #Column check
li $t3, 0
outerCC:
 bge $t3, $t1, checkDiagonal # Move to diagonal check if nothing found
 li $t4, 0

 sll $t6, $t3, 2
 add $t5, $t6, $zero
 add $t5, $s0, $t5
 lw $t7, 0($t5)
 addi $t5, $t5, 12
 lw $t8, 0($t5)
 addi $t5, $t5, 12
 lw $t9, 0($t5)

 
 addi $t3, $t3, 1
 
 beq $t8, '-', outerCC
 seq $t0,$t7,$t8
 seq $t9,$t8,$t9
 beq $t0, $zero, outerCC
 beq $t0,$t9, Win
 
 b outerCC
 
checkDiagonal: #Diagonal check
 move $t5, $zero
 add $t5, $s0, $t5

 lw $t7, 0($t5)
 add $t5, $t5, 16
 lw $t8, 0($t5)
 add $t5, $t5, 16
 lw $t9, 0($t5)
 
 beq $t8, '-', secondDiagonal
 seq $t0,$t7,$t8
 seq $t9,$t8,$t9
 beq $t0, $zero, secondDiagonal
 beq $t0,$t9, Win
 
 secondDiagonal:
 li $t5, 8
 add $t5, $s0, $t5
 
 lw $t7, 0($t5)
 add $t5, $t5, 8
 lw $t8, 0($t5)
 add $t5, $t5, 8
 lw $t9, 0($t5)
 
 beq $t8, '-', continue
 seq $t0,$t7,$t8
 seq $t9,$t8,$t9
 beq $t0, $zero, continue
 beq $t0,$t9, Win
 
continue: # Check for draw or no winner yet
beq $a2, 9, Draw
jr $ra

Win: # Win function ends game
li $v0, 4
la $a0, prompt5
syscall

li $v0, 10
syscall

Draw: # Draw function ends game
li $v0, 4
la $a0, prompt7
syscall

li $v0, 10
syscall

playerTurn: #Player moves
li $v0, 4
la $a0, prompt2
syscall

li $v0, 5 # Row input
syscall
move $t3, $v0

li $v0, 4
la $a0, prompt3
syscall

li $v0, 5 # Column input
syscall
move $t4, $v0


sll $t6, $t3, 2
sll $t7, $t4, 2
mul $t5, $t6, $t2  
add $t5, $t5, $t7      
add $t5, $s0, $t5

li $v1, 'X'

lw $s1, 0($t5)
beq $s1, '-', exitTurn #Ensures player does not select an already choses space
b playerTurn
exitTurn:
jr $ra

Random:
li $a1, 3 
li $v0, 42  #generates a random number 0-2 for row
syscall
move $t3, $a0

li $a1, 3
li $v0, 42  #generates a random number 0-2 for column
syscall
move $t4, $a0

sll $t6, $t3, 2
sll $t7, $t4, 2
mul $t5, $t6, $t2  
add $t5, $t5, $t7      
add $t5, $s0, $t5

li $v1, 'O'
lw $s1, 0($t5) #Loops if square is occupied and tries another random one
beq $s1, '-', exitRandom
b Random
exitRandom:
jr $ra
