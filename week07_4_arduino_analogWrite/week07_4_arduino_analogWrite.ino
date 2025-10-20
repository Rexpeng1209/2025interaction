//week07_4_arduino_analogWrite
void setup() {
  // put your setup code here, to run once:
  pinMode(11,OUTPUT);// 第11個pin腳(有PWM功能, 可0~255輸出), 要輸出
}// 這些特別的腳, 分別是 第3 第5 第6 第9 第10 第11, 共6個腳, 都可以控制亮度
int a=0;
void loop() {
  // put your main code here, to run repeatedly:
  analogWrite(11, a);//亮的程度,是a的值
  a= (a+1) % 256;//會再亮一點點
  delay(10);//每 0.01 秒
}
