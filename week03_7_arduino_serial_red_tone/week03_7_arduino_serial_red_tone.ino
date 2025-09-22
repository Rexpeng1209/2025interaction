//week03_7_arduino_serial_red_tone
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);//設定usb傳輸速度
  pinMode(8,OUTPUT);//8要會發聲
}

void serialEvent(){//等待usb事件
  while (Serial.available()){ //若有資料
    Serial.read();
    tone(8,800,200);
  }
}
void loop() {
  // put your main code here, to run repeatedly:

}
