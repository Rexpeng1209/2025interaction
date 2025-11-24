//week12_2_dino_jump_part2_board_if_dy
//修改自week12_1_dino_jump_part1_loadImage_dy_jump
//恐龍跳跳跳(3)板子(4)卡在板子上
PImage img;
void setup(){
  size(300,500);
  img = loadImage("dino.png");
}
float boardX = 200, boardY = 400;
float x = 200, y = 400, dx = 0, dy = 0;
void draw(){
  background(255);
  rect(boardX, boardY, 100, 5);
  image(img, x, y, 100, 100);
  if(y+100 <= boardY && y+dy+100 >= boardY){
    y= boardY-100;
    dy= 0;
  }else{
    y+=dy;
    if(y<400) dy += 0.98;
    else dy = 0;
  }
}
void keyPressed(){
  if(keyCode==UP) dy = -15;
}
