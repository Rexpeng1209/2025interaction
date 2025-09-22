//week03_8_processing_serial_write_space
import processing.serial.*;//使用serial外掛
Serial myPort;
void setup(){
  size(400,400);
  myPort = new Serial(this, "COM5",9600);
}
void mousePressed(){
  if(mouseButton==LEFT) myPort.write('b');
  if(mouseButton==RIGHT) myPort.write(' ');
}
void draw(){
  if(mousePressed) background(#FF0000);
  else background(#00FF00);
}
