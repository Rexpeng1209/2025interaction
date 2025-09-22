//week03_5_pin2_Button_digitalRead_digitalWrite
//手動按按鈕，看到燈慢慢改變now之後把now變亮
void setup() {
  // put your setup code here, to run once:
  pinMode(2, INPUT_PULLUP);//按鈕是二號，沒接下去，就會拉高
  for(int i=3;i<=13;i++){//把 pin 3,4,5....,13都設成output
    pinMode(i, OUTPUT);//都是可以發光
  }
}
int now = 3;//現在發亮的是pin3
void loop() {
  // put your main code here, to run repeatedly:
  if(digitalRead(2)==LOW){//按下去了
  now = now+1;
  if(now>13) now = 3;
  for(int i=3;i<13;i++){
    digitalWrite(i, LOW);//全部清空變成low不亮
  }
  digitalWrite(now, HIGH);//now 負責亮
  delay(500);//休息一下
}
}
