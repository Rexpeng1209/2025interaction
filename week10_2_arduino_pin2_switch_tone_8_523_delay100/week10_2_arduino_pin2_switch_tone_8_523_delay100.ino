//week10_2_arduino_pin2_switch_tone_8_523_delay100
void setup() {
  pinMode(2, INPUT_PULLUP);//拉高,變成5v,真的按下去,變0v(GND接他)

}//pin 2變成按鈕,可以HIGH高(沒按) 可以LOW低(按)

void loop() {
  if(digitalRead(2)==LOW){//如果pin2有按下去
    tone(8,523,100);//發出523的Do
    delay(100);
    tone(8,784,100);//發出784的so
    delay(100);
  }

}
