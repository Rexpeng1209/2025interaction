//動很快也不會漏掉因為永遠都準確的追蹤
void setup(){
  size(500,500);
}
int x=200, y=250;
void draw(){
  background(#FFFFAA);
  rect(x,y,100,50);
}
void mouseDragged(){
  if(mousePressed && x < mouseX && mouseX < x + 100 && y < mouseY && mouseY < y+50){
    x += mouseX - pmouseX;
    y += mouseY - pmouseY;
  }
}
