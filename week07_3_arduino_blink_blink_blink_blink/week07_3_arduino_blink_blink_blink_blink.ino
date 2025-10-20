//week07_3_arduino_blink_blink_blink_blink
//修改自week07_2_arduino_blink_blink 多插2支
//麵包版每5格為1版
//小心,有一支腳要接地GND ,另一支接13
//小心,有一支腳要接地GND ,另一支接12
//小心,有一支腳要接地GND ,另一支接11
//小心,有一支腳要接地GND ,另一支接10
void setup() {
  // put your setup code here, to run once:
  pinMode(10,OUTPUT);// 把第10支腳,能送出資料 OUTPUT
  pinMode(11,OUTPUT);// 把第11支腳,能送出資料 OUTPUT
  pinMode(12,OUTPUT);// 把第12支腳,能送出資料 OUTPUT
  pinMode(13,OUTPUT);// 把第13支腳,能送出資料 OUTPUT
  
}

void loop() {
  // put your main code here, to run repeatedly:
  for(int i=10; i<=13;i++){
    digitalWrite(13,LOW);// 暗掉
    digitalWrite(i-1,LOW);// 暗掉
    digitalWrite(i,HIGH);// 發亮
    delay(500);
  }
}