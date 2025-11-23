//week11_1_processing_serial_joystick_x_y_better
//修改自week10_7_processing_serial_joystick_x_y
import processing.serial.*;
Serial myPort;
void setup(){
  size(512, 512);
  myPort = new Serial(this ,"COM7", 9600);
}
int x = 128, y = 128;
void draw(){
  background(#FFFFA0);
  ellipse(x*2, y*2, 8, 8);
  if( myPort.available() > 0){
    x = myPort.read();
    y = myPort.read();
    println( "x:" + x + "y:" + y);// 加這行, 觀察數值
  }
}
