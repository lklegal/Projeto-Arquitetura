#####################################################################
#
# Ludo project
# ##############
#
# Developers:
#	 Ramon Nepomuceno
#	 Luiz Kaio
# ##############
#
# Bitmap Display Configuration:
# ###############
# - Unit width in pixels: 16                                          
# - Unit height in pixels: 16
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#####################################################################

.data
	
	current_position_v:	.word	0, 0, 0, 0
	previous_colors_v: 	.word	0x008000, 0xFF0000, 0x0000FF, 0xFFFF00
	current_player:		.word   0
	players_colors:		.word   green_name, red_name, blue_name, yellow_name
	
	green_name:			.asciiz "Verde"			
	red_name:			.asciiz "Vermelho"
	blue_name:			.asciiz "Azul"
	yellow_name:			.asciiz "Amarelo"
	
	dice_roll_message_1:            .asciiz "Jogador "
	dice_roll_message_2:            .asciiz " rolou os dados, e tirou o numero "
	victory_message:                .asciiz "Ganhou!"
	
	next_position:          .word   0
	dice_roll_result:       .word   3
	
	players_paths_m:	.word   green_path, red_path, blue_path, yellow_path
	players_colors_v:	.word   0x00ff00, 0xff708e, 0x00008B, 0xffa500
	
		
	green:  		.word 	0x008000
	dark_green:     	.word 	0x00ff00
	red:	        	.word 	0xFF0000
	dark_red:		.word 	0xff708e
	blue:	        	.word 	0x0000FF
	dark_blue:		.word 	0x00008B
	dark_yellow:    	.word 	0xffa500
	yellow:         	.word 	0xFFFF00	
		
	path_size:		.word	57
	green_path:		.word 	17,97,98,99,100,101,86,70,54,38,22,6,7,8,24,40,56,72,88,105,106,107,108,109,110,126,142,141,140,139,138,137,152,168,184,200,216,232,231,230,214,198,182,166,150,133,132,131,130,129,128,112,113,114,115,116,117,118
	red_path:		.word	26,24,40,56,72,88,105,106,107,108,109,110,126,142,141,140,139,138,137,152,168,184,200,216,232,231,230,214,198,182,166,150,133,132,131,130,129,128,112,96,97,98,99,100,101,86,70,54,38,22,6,7,23,39,55,71,87,103
	blue_path:		.word   170,141,140,139,138,137,152,168,184,200,216,232,231,230,214,198,182,166,150,133,132,131,130,129,128,112,96,97,98,99,100,101,86,70,54,38,22,6,7,8,24,40,56,72,88,105,106,107,108,109,110,126,125,124,123,122,121,120
	yellow_path:		.word	161,214,198,182,166,150,133,132,131,130,129,128,112,96,97,98,99,100,101,86,70,54,38,22,6,7,8,24,40,56,72,88,105,106,107,108,109,110,126,142,141,140,139,138,137,152,168,184,200,216,232,231,215,199,183,167,151,135

.text

	jal draw_board
main_loop:
	jal roll_dice
	lw $t0, current_player
	sll $t0, $t0, 2
	la $t1, current_position_v
	add $t1, $t1, $t0
	lw $t2, 0($t1) #current_position_v[current_player]
	seq $t4, $t2, $zero #if(current_position_v[current_player] == 0)
	lw $t3, dice_roll_result
	sne $t5, $t3, 6 # if(number != 6)
	and $t6, $t5, $t4
	beq $t6, 1, change_player_condition #if(current_position_v[current_player] == 0 && number != 6)
	jal try_move #try_move();
	beq $t3, 6, main_loop #while(number == 6);
change_player_condition:
	lw $t0, current_player
	beq $t0, 3, change_player_condition_true #if(current_player == 3)
	addi $t0, $t0, 1 #current_player++;
	j change_player_condition_false
change_player_condition_true: #else:
	li $t0, 0 #current_player = 0
change_player_condition_false:
	sw $t0, current_player
	j main_loop

exit_game:
	li $v0, 4
	la $a0, victory_message
	syscall #imprime "Ganhou!"
	li $v0,10
	syscall
	
try_move:
	#j exit_game
	lw $t0, current_player
	sll $t0, $t0, 2
	la $t1, current_position_v
	add $t1, $t1, $t0
	lw $t2, 0($t1) #current_position_v[current_player]
	lw $t3, dice_roll_result
	add $t3, $t3, $t2 #current_position_v[current_player] + step
	sgt $t4, $t3, 57 #if((current_position_v[current_player] + step) > 57),|||| 57 => path_size
	beq $t4, 1, change_player_condition #not jumping back to $ra because, in this case, we don't want the player to roll the dice again if they got a 6
	beq $t3, 57, exit_game #if((current_position_v[current_player] + step) == 57),|||| 57 => path_size, jumps to exit_game
	beq $t2, 0, current_position_is_0 #if(current_position_v[current_player] == 0)
	#else
	sw $t3, next_position #next_position = current_position_v[current_player] + step
	j end_if_current_position_is_0
current_position_is_0:
	li $t3, 1
	sw $t3, next_position #next_position = 1
end_if_current_position_is_0:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $a0, next_position
	lw $a1, current_player
	jal check_if_kills #check_if_kills(next_position, current_player)
	lw $a0, current_player
	lw $a1, next_position
	jal move_player #move_player(next_position, current_player)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
move_player:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	sll $a1, $a1, 2
	add $t0, $a1, $a2 #pixel_to_move = paths[player][next_position], but as an address, not a value
	la $t2, current_position_v
	sll $a0, $a0, 2
	add $t2, $t2, $a0
	lw $t1, 0($t2) #current_position_v[player]
	sll $t1, $t1, 2
	add $t2, $a2, $t1 #current_pixel = paths[player][current_position_v[player]]
	lw $t2, 0($t2) #current_pixel = paths[player][current_position_v[player]]
	la $t3, previous_colors_v
	add $t3, $t3, $a0
	lw $t3, 0($t3) #previous_color_v[player]
	sll $t2, $t2, 2
	add $t4, $t2, $gp
	sw $t3, 0($t4) #board[current_pixel] = previous_color_v[player]
	la $t3, previous_colors_v
	add $t3, $t3, $a0 #previous_color_v[player], but as an address, not a value
	lw $t0, 0($t0) #pixel_to_move = paths[player][next_position]
	sll $t0, $t0, 2
	add $t4, $t0, $gp #board[pixel_to_move], but as an address, not a value
	lw $t4, 0($t4) #getting the new previous_color from the position in the board the player will move to
	sw $t4, 0($t3) #previous_color_v[player]= board[pixel_to_move]
	add $t4, $t0, $gp #board[pixel_to_move], but as an address, not a value
	sw $a3, 0($t4) #board[pixel_to_move]=players_colors[player]
	la $t2, current_position_v
	add $t2, $t2, $a0
	srl $a1, $a1, 2 #dividing next_position by 4
	sw $a1, 0($t2) #current_position_v[player] = position_to_move
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

check_if_kills:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#there's no matrix here for the players and their positions, only four vectors, so i'll have to do things the hard way
	beq $a1, 0, is_player_0
	beq $a1, 1, is_player_1
	beq $a1, 2, is_player_2
	beq $a1, 3, is_player_3
is_player_0:
	la $s1, green_path
	lw $s2, dark_green
	sll $t2, $a0, 2
	add $t2, $t2, $s1 #paths[0][next_position]
	lw $t2, 0($t2)
	j end_of_which_player_it_is_check
is_player_1:
	la $s1, red_path
	lw $s2, dark_red
	sll $t2, $a0, 2
	add $t2, $t2, $s1 #paths[1][next_position]
	lw $t2, 0($t2)
	j end_of_which_player_it_is_check
is_player_2:
	la $s1, blue_path
	lw $s2, dark_blue
	sll $t2, $a0, 2
	add $t2, $t2, $s1 #paths[2][next_position]
	lw $t2, 0($t2)
	j end_of_which_player_it_is_check
is_player_3:
	la $s1, yellow_path
	lw $s2, dark_yellow
	sll $t2, $a0, 2
	add $t2, $t2, $s1 #paths[3][next_position]
	lw $t2, 0($t2)
	j end_of_which_player_it_is_check
end_of_which_player_it_is_check:
	#check if green dies
	la $t3, current_position_v
	la $t4, green_path
	lw $t3, 0($t3)
	sll $t3, $t3, 2
	add $t4, $t4, $t3 #paths[0][current_position_v[0]]
	lw $t4, 0($t4)
	beq $t4, $t2, player_0_dies 
	#check if red dies
	la $t3, current_position_v
	la $t4, red_path
	lw $t3, 4($t3)
	sll $t3, $t3, 2
	add $t4, $t4, $t3 #paths[1][current_position_v[1]]
	lw $t4, 0($t4)
	beq $t4, $t2, player_1_dies
	#check if blue dies
	la $t3, current_position_v
	la $t4, blue_path
	lw $t3, 8($t3)
	sll $t3, $t3, 2
	add $t4, $t4, $t3 #paths[2][current_position_v[2]]
	lw $t4, 0($t4)
	beq $t4, $t2, player_2_dies
	#check if yellow dies
	la $t3, current_position_v
	la $t4, yellow_path
	lw $t3, 12($t3)
	sll $t3, $t3, 2
	add $t4, $t4, $t3 #paths[3][current_position_v[3]]
	lw $t4, 0($t4)
	beq $t4, $t2, player_3_dies
	j end_of_check_if_kills
player_0_dies:
	li $a0, 0
	la $a2, green_path #not ideal, but, to not have to check again which player will move, i'm saving the target player's path array in $a2 to reuse it in move_player
	lw $a3, dark_green 
	li $a1, 0
	jal move_player
	j end_of_check_if_kills
player_1_dies:
	li $a0, 1
	la $a2, red_path #not ideal, but, to not have to check again which player will move, i'm saving the target player's path array in $a2 to reuse it in move_player
	lw $a3, dark_red
	li $a1, 0
	jal move_player
	j end_of_check_if_kills
player_2_dies:
	li $a0, 2
	la $a2, blue_path #not ideal, but, to not have to check again which player will move, i'm saving the target player's path array in $a2 to reuse it in move_player
	lw $a3, dark_blue
	li $a1, 0
	jal move_player
	j end_of_check_if_kills
player_3_dies:
	li $a0, 3
	la $a2, yellow_path #not ideal, but, to not have to check again which player will move, i'm saving the target player's path array in $a2 to reuse it in move_player 
	lw $a3, dark_yellow
	li $a1, 0
	jal move_player
	j end_of_check_if_kills
end_of_check_if_kills:
	add $a2, $zero, $s1 #not ideal, but, to not have to check again which player will move, i'm saving the result of $s1 in $a2 to reuse it in move_player
	add $a3, $zero, $s2
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

roll_dice:
	li $v0, 4
	la $a0, dice_roll_message_1
	syscall #prints "Jogador "
	li $v0, 1
	lw $a0, current_player
	addi $a0, $a0, 1
	syscall #prints the number of the current player
	li $v0, 4
	la $a0, dice_roll_message_2
	syscall #prints " rolou os dados, e tirou o numero "
	li $v0, 42
	li $a1, 6
	syscall #randomly picks a number from 0 to 5
	addi $a0, $a0, 1 #adds 1 to the randomly picked number, so that it becomes a number between 1 and 6
	sw $a0, dice_roll_result
	li $v0, 1
	syscall #prints the number between 1 and 6
	li $v0, 12
	syscall #waits for an input from the player
	jr $ra

draw_board:

	#store registers $s*
	addi $sp, $sp, -36
	sw $s0, 0 ($sp) 
	sw $s1, 4 ($sp)
	sw $s2, 8 ($sp)
	sw $s3, 12 ($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7, 28 ($sp)
	sw $ra, 32 ($sp)
	##------

	lw $t0, green
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 0
	li $a1, 0
	jal draw_square
	
	lw $t0, red
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 0
	li $a1, 9
	jal draw_square	
	
	lw $t0, yellow
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 9
	li $a1, 0
	jal draw_square
	
	lw $t0, blue
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 9
	li $a1, 9
	jal draw_square

	lw $t0, green
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 7
	li $a1, 1	
	jal draw_line

	lw $t0, blue
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 7
	li $a1, 8	
	jal draw_line

	lw $t0, red
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 1
	li $a1, 7	
	jal draw_colum
	
	lw $t0, yellow
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 8
	li $a1, 7	
	jal draw_colum
	
	
## dots green
	lw $t0, dark_green
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 1
	li $a1, 1	
	jal draw_dot	
	
	
## red dots 
	lw $t0, dark_red
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 1
	li $a1, 10	
	jal draw_dot	


## yellow dots 
	lw $t0, dark_yellow
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 10
	li $a1, 1	
	jal draw_dot	

## blue dots 
	lw $t0, dark_blue
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 10
	li $a1, 10	
	jal draw_dot

		##----
	lw $s0, 0 ($sp) 
	lw $s1, 4 ($sp)
	lw $s2, 8 ($sp)
	lw $s3, 12 ($sp)
	lw $s4, 16 ($sp)
	lw $s5, 20 ($sp)
	lw $s6, 24 ($sp)
	lw $s7, 28 ($sp)
	lw $ra, 32 ($sp)
	addi $sp, $sp, 36
	jr $ra	
		
				
#for(i=0;i<6;i++)
#  for(j=0;j<6;j++)
#     image[i*16][j] = green
#    

draw_square:
	lw $s3, 0 ($sp)
	addi $sp, $sp, 4
	#store registers $s0,
	addi $sp, $sp, -36
	sw $s0, 0 ($sp) 
	sw $s1, 4 ($sp)
	sw $s2, 8 ($sp)
	sw $s3, 12 ($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7, 28 ($sp)
	sw $ra, 32 ($sp)
	
	move $t0, $a0 	 # i
	addi $t1, $a0, 6 
for_i:	li $t3, 0
	slt $t3, $t0, $t1 # i < 6
	beq $t3, $zero, exit_for_i
	move $t4, $a1 # j
	add $t5 , $a1, 6
for_j:	li $t3, 0
	slt $t3, $t4, $t5 # i < 6
	beq $t3, $zero, exit_for_j
	lw $s0, green
	sll $s2, $t0, 4	  # i*16
	add $s2, $s2, $t4 # i*16+j
	sll $s2, $s2, 2   # (i*16+j)*4
	add $s2, $s2, $gp # img[i*16][j]
	sw  $s3, 0 ($s2)   #
	add $t4, $t4, 1
	j for_j
exit_for_j:
	add $t0, $t0, 1
	j for_i
exit_for_i:
	##----
	lw $s0, 0 ($sp) 
	lw $s1, 4 ($sp)
	lw $s2, 8 ($sp)
	lw $s3, 12 ($sp)
	lw $s4, 16 ($sp)
	lw $s5, 20 ($sp)
	lw $s6, 24 ($sp)
	lw $s7, 28 ($sp)
	lw $ra, 32 ($sp)
	addi $sp, $sp, 36
	jr $ra	
	
	
#for(i;i<6;i++)
#	image[i*16]=		
draw_line:
	lw $s3, 0 ($sp)
	addi $sp, $sp, 4
	#store registers $s0,
	addi $sp, $sp, -36
	sw $s0, 0 ($sp) 
	sw $s1, 4 ($sp)
	sw $s2, 8 ($sp)
	sw $s3, 12 ($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7, 28 ($sp)
	sw $ra, 32 ($sp)

	move $t0, $a0
	move $t4, $a1 # j
	add $t5 , $a1, 6
for_j_line:
	li $t3, 0
	slt $t3, $t4, $t5 # i < 6
	beq $t3, $zero, exit_for_line
	lw $s0, green
	sll $s2, $t0, 4	  # i*16
	add $s2, $s2, $t4 # i*16+j
	sll $s2, $s2, 2   # (i*16+j)*4
	add $s2, $s2, $gp # img[i*16][j]
	sw  $s3, 0 ($s2)   #
	add $t4, $t4, 1
	j for_j_line
exit_for_line:
	##----
	lw $s0, 0 ($sp) 
	lw $s1, 4 ($sp)
	lw $s2, 8 ($sp)
	lw $s3, 12 ($sp)
	lw $s4, 16 ($sp)
	lw $s5, 20 ($sp)
	lw $s6, 24 ($sp)
	lw $s7, 28 ($sp)
	lw $ra, 32 ($sp)
	addi $sp, $sp, 36
	jr $ra
	
			
draw_colum:
	lw $s3, 0 ($sp)
	addi $sp, $sp, 4
	#store registers $s0,
	addi $sp, $sp, -36
	sw $s0, 0 ($sp) 
	sw $s1, 4 ($sp)
	sw $s2, 8 ($sp)
	sw $s3, 12 ($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7, 28 ($sp)
	sw $ra, 32 ($sp)
	
	
	move $t0, $a0 # i
	move $t4, $a1 # j
	add $t5 , $a0, 6
for_j_colum:
	li $t3, 0
	slt $t3, $t0, $t5 # j < 6
	beq $t3, $zero, exit_for_colum
	sll $s2, $t0, 4	  # i*16
	add $s2, $s2, $t4 # i*16+j
	sll $s2, $s2, 2   # (i*16+j)*4
	add $s2, $s2, $gp # img[i*16][j]
	sw  $s3, 0 ($s2)   #
	add $t0, $t0, 1
	j for_j_colum
exit_for_colum:
		##----
	lw $s0, 0 ($sp) 
	lw $s1, 4 ($sp)
	lw $s2, 8 ($sp)
	lw $s3, 12 ($sp)
	lw $s4, 16 ($sp)
	lw $s5, 20 ($sp)
	lw $s6, 24 ($sp)
	lw $s7, 28 ($sp)
	lw $ra, 32 ($sp)
	addi $sp, $sp, 36
	jr $ra

draw_dot:
	lw $s3, 0 ($sp)
	addi $sp, $sp, 4
	#store registers $s0,
	addi $sp, $sp, -36
	sw $s0, 0 ($sp) 
	sw $s1, 4 ($sp)
	sw $s2, 8 ($sp)
	sw $s3, 12 ($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7, 28 ($sp)
	sw $ra, 32 ($sp)
	
	move $t0, $a0      # i
	move $t4, $a1 	   # j
	sll $s2, $t0, 4	   # i*16
	add $s2, $s2, $t4  # i*16+j
	sll $s2, $s2, 2    # (i*16+j)*4
	add $s2, $s2, $gp  # img[i*16][j]
	sw  $s3, 0 ($s2)   # 
		##----
	lw $s0, 0 ($sp) 
	lw $s1, 4 ($sp)
	lw $s2, 8 ($sp)
	lw $s3, 12 ($sp)
	lw $s4, 16 ($sp)
	lw $s5, 20 ($sp)
	lw $s6, 24 ($sp)
	lw $s7, 28 ($sp)
	lw $ra, 32 ($sp)
	addi $sp, $sp, 36
	jr $ra
