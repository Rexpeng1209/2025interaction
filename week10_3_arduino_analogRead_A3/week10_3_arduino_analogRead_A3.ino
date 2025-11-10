//week10_3_arduino_analogRead_A3
//把 joystick 的 y 線,按到 MakerUno A3
//(不能接其他的,因為要接有 小蟲符號的,代表analog訊號)
void setup() {
  
  pinMode(2, INPUT_PULLUP);//pin2按鈕 可以高(沒按) 可以低(按)
  pinMode(8, OUTPUT);

}

void loop() {
  int now = analogRead(A3);
  if(now>800)
  {
    tone(8,523,100);
    delay(100);
    tone(8,784,100);
    delay(200);
  }
  else if(now<200)
  {
    tone(8,784,100);
    delay(100);
    tone(8,523,100);
    delay(200);
  }

}
