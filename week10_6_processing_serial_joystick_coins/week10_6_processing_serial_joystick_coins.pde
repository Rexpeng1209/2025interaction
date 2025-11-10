//week10_6_processing_serial_joystick_coins
//利用 USB Serial 傳搖桿的量讓板子左右移動
import processing.serial.*;
Serial myPort;
void setup(){
  size(500,500);
  myPort = new Serial(this, "COM5",9600);
  rectMode(CENTER);//四邊形的中心當成座標
}
int x = 250,y = 400, now;
float dx = 0;
void draw(){
  background(#FFFFA0);
  rect(x,y,100,20);
  if(myPort.available()>0){
    now = myPort.read();//0-255
    dx = (now-127)/10.0;//-128 - +127
    if(abs(dx)<0.21) dx = 0;//因為有殘值所以太小就設0
  }
  x += dx;
}
