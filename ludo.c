#include <time.h>
#include <stdlib.h>
#include <stdio.h>


#define SIZE 16

// Symbols representing colors on the board
#define GREEN '$'   
#define BLUE '#'
#define YELLOW '@'
#define  RED '*'

// Symbols representing pawns on the board
#define GREEN_PLAYER 'G'
#define BLUE_PLAYER 'B'
#define YELLOW_PLAYER 'Y'
#define  RED_PLAYER 'R'

// // paths that can be taken by each player (green, red, blue and yellow)
int players_path_m[4][58]={
{17,97,98,99,100,101,86,70,54,38,22,6,7,8,24,40,56,72,88,105,106,107,108,109,110,126,142,141,140,139,138,137,152,168,184,200,216,232,231,230,214,198,182,166,150,133,132,131,130,129,128,112,113,114,115,116,117,118},
{170,141,140,139,138,137,152,168,184,200,216,232,231,230,214,198,182,166,150,133,132,131,130,129,128,112,96,97,98,99,100,101,86,70,54,38,22,6,7,8,24,40,56,72,88,105,106,107,108,109,110,126,125,124,123,122,121,120},
{26,24,40,56,72,88,105,106,107,108,109,110,126,142,141,140,139,138,137,152,168,184,200,216,232,231,230,214,198,182,166,150,133,132,131,130,129,128,112,96,97,98,99,100,101,86,70,54,38,22,6,7,23,39,55,71,87,103},
{161,214,198,182,166,150,133,132,131,130,129,128,112,96,97,98,99,100,101,86,70,54,38,22,6,7,8,24,40,56,72,88,105,106,107,108,109,110,126,142,141,140,139,138,137,152,168,184,200,216,232,231,215,199,183,167,151,135}};



int current_position_v[] = {0,0,0,0}; // current position of each player (green, red, blue and yellow)
char previous_color_v[]   = {GREEN,RED,BLUE,YELLOW}; // old position value (green, red, blue and yellow) used to refresh the screen
char players_colors[]     = {GREEN_PLAYER,RED_PLAYER,BLUE_PLAYER,YELLOW_PLAYER}; // player's pawn (green, red, blue and yellow)
int current_player = 0; // player who is currently playing
int path_size = 57;     // total length of the path taken to win the game
int board[SIZE*SIZE];   

int roll_dice();     
void draw_square(int ii, int jj, char color);
void draw_line(int ii, int jj, char color);
void draw_colum(int ii, int jj, char color);
void draw_dot(int ii, int jj, char color);
void render_initial_board();
int roll_dice();
void try_move(int step);
void move_player(int player, int position_to_move);
void check_if_kills(int next_position);
void render();

int main(){
  srand(time(NULL));   // Initialization, should only be called once.
  render_initial_board();
  render();
  int number;
  while(1){
    do{
      number = roll_dice();
      if(current_position_v[current_player] == 0 && number != 6)		// if you're at the beginning and didn't roll a six
        break;
      try_move(number); 
    }while(number==6);
    current_player = current_player==3 ? 0 : current_player + 1; // pass the turn
  }

}

void render(){
  system("clear");  // clears the screen (you can remove that line, it only works on linux)
  for (int i = 0; i < SIZE; i++){
    for (int j = 0; j < SIZE; j++){
      printf("|%c", board[i*SIZE+j]);
    }
    printf("|\n");
  }
  return;
}

void draw_square(int ii, int jj, char color){
  for(int i = ii; i < ii+6; i++){
    for(int j =jj; j<jj+6; j++){
      board[i*SIZE + j]=color;
    }
  }
  return;
}

void draw_line(int ii, int jj, char color){
  for(int j =jj; j<jj+6; j++){
    board[ii*SIZE + j]=color;
  }
  return;
}

void draw_colum(int ii, int jj, char color){
  for(int i =ii; i<ii+6; i++){
    board[i*SIZE + jj]=color;
  }
  return;
}

void draw_dot(int ii, int jj, char color){
  board[ii*SIZE + jj]=color;
  return;  
}


void render_initial_board(){
  for(int i=0;i<SIZE;i++){
    for(int j=0; j< SIZE; j++){
      board[i*SIZE + j] = ' ';
    }
  }

  draw_square(0,0,GREEN);
  draw_square(0,9,RED);
  draw_square(9,9,BLUE);
  draw_square(9,0,YELLOW);

  draw_line(7,1,GREEN);
  draw_line(7,8,BLUE);
  draw_colum(1,7,RED);
  draw_colum(8,7,YELLOW);

  draw_dot(1,1, GREEN_PLAYER);
  draw_dot(1,10, RED_PLAYER);
  draw_dot(10,10, BLUE_PLAYER);
  draw_dot(10,1, YELLOW_PLAYER);
  return;
}

int roll_dice(){
    printf("Jogador %c rolou os dados ", players_colors[current_player]);
    int r = (rand()%6)+1; 
    printf("e tirou o numero: %d", r);
    getchar();
    return r;
}


void try_move(int step){                                                
  if((current_position_v[current_player] + step) > path_size) return;  // if passes from the position of winning
  if((current_position_v[current_player] + step) == path_size) {      // if won
    printf("ganhou");
    exit(0);
  }
  int next_position;
  if(current_position_v[current_player]==0){ // if you are starting to move
    next_position = 1;
  }else{  // if it is moving normally
    int current_position = current_position_v[current_player]; // get the current position index of the current player
    next_position  = current_position + step; // sum with step to calculate next index
  }
  
  check_if_kills(next_position); // check if the move will kill someone
  move_player(current_player, next_position); // move the pawn to the next position
  return;
}

void move_player(int player, int position_to_move){

  int pixel_to_move = players_path_m[player][position_to_move]; // finds which pixel to move to
  int current_pixel = players_path_m[player][current_position_v[player]]; // find out which pixel the player is on
  
  board[current_pixel] = previous_color_v[player]; // remove the player from the current position
  
  previous_color_v[player]=board[pixel_to_move]; // saves the color of the position where it will move
  
  board[pixel_to_move]=players_colors[player]; // move the player to position
  
  current_position_v[player] = position_to_move; // updates the position of the player who was moved
  
  render(); // render the screen
  return;
}


void check_if_kills(int next_position){         
  int target_pixel = players_path_m[current_player][next_position]; // find out which pix to move to
  for(int i=0;i<4;i++){ // cycle through all players
    if(players_path_m[i][current_position_v[i]] == target_pixel) // checks if player i is in the position you want to move to
      move_player(i, 0); // if so, move player i to the starting position
  }
  return;
}


